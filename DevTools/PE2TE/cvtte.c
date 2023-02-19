#include <Uefi.h>
#include <IndustryStandard/PeImage.h>
#include <Library/BaseMemoryLib.h>

VOID* PageAlloc(IN UINTN Size);
BOOLEAN PageFree(IN VOID* Memory);
UINT32 ConsolePrintfA(IN CHAR8 *Format,...);

VOID* GetTeImageSection(IN VOID* TeImage,IN INT32 Index,OUT UINT32 *Size,OUT UINT32 *FileOffset)
{
	EFI_TE_IMAGE_HEADER *TeHead=(EFI_TE_IMAGE_HEADER*)TeImage;
	if(Index==-1)
	{
		*Size=sizeof(EFI_TE_IMAGE_HEADER);
		*Size+=sizeof(EFI_IMAGE_SECTION_HEADER)*TeHead->NumberOfSections;
		*FileOffset=0;
		return TeImage;
	}
	else if(Index>=0 && Index<TeHead->NumberOfSections)
	{
		EFI_IMAGE_SECTION_HEADER *SectionHeaders=(EFI_IMAGE_SECTION_HEADER*)((UINTN)TeImage+sizeof(EFI_TE_IMAGE_HEADER));
		*FileOffset=SectionHeaders[Index].PointerToRawData;
		*Size=SectionHeaders[Index].SizeOfRawData;
		return (VOID*)((UINTN)TeImage+SectionHeaders[Index].VirtualAddress);
	}
	return NULL;
}

UINT32 GetTeImageSize(IN VOID* TeImage)
{
	EFI_TE_IMAGE_HEADER *TeHead=(EFI_TE_IMAGE_HEADER*)TeImage;
	UINT32 VaMax=0,SectionSize=0;
	if(TeHead->Signature==EFI_TE_IMAGE_HEADER_SIGNATURE)
	{
		EFI_IMAGE_SECTION_HEADER *SectionHeaders=(EFI_IMAGE_SECTION_HEADER*)((UINTN)TeImage+sizeof(EFI_TE_IMAGE_HEADER));
		for(UINT8 i=0;i<TeHead->NumberOfSections;i++)
		{
			if(SectionHeaders[i].VirtualAddress>VaMax)
			{
				VaMax=SectionHeaders[i].VirtualAddress;
				SectionSize=SectionHeaders[i].SizeOfRawData;
			}
		}
	}
	return VaMax+SectionSize;
}

BOOLEAN ConvertToTerseExecutableImage(IN VOID* PeImage,OUT VOID* TeImage)
{
	EFI_IMAGE_DOS_HEADER *DosHead=PeImage;
	if(DosHead->e_magic==EFI_IMAGE_DOS_SIGNATURE)
	{
		EFI_IMAGE_OPTIONAL_HEADER_UNION *NtHeadUnion=(EFI_IMAGE_OPTIONAL_HEADER_UNION*)((UINTN)PeImage+DosHead->e_lfanew);
		if(NtHeadUnion->Pe32.Signature==EFI_IMAGE_NT_SIGNATURE)
		{
			EFI_TE_IMAGE_HEADER *TeHead=TeImage;
			UINT16 Magic=NtHeadUnion->Pe32.OptionalHeader.Magic;
			UINT16 PeHeaderSize=(UINT16)(DosHead->e_lfanew+sizeof(UINT32)+sizeof(EFI_IMAGE_FILE_HEADER)+NtHeadUnion->Pe32.FileHeader.SizeOfOptionalHeader);
			EFI_IMAGE_SECTION_HEADER *TeSections=(EFI_IMAGE_SECTION_HEADER*)((UINTN)TeImage+sizeof(EFI_TE_IMAGE_HEADER));
			EFI_IMAGE_SECTION_HEADER *PeSections=(EFI_IMAGE_SECTION_HEADER*)((UINTN)PeImage+PeHeaderSize);
			// Copy from Optional Header.
			switch(Magic)
			{
				case EFI_IMAGE_NT_OPTIONAL_HDR32_MAGIC:
				{
					EFI_IMAGE_NT_HEADERS32* NtHead=&NtHeadUnion->Pe32;
					TeHead->Subsystem=(UINT8)NtHead->OptionalHeader.Subsystem;
					TeHead->AddressOfEntryPoint=NtHead->OptionalHeader.AddressOfEntryPoint;
					TeHead->BaseOfCode=NtHead->OptionalHeader.BaseOfCode;
					TeHead->ImageBase=NtHead->OptionalHeader.ImageBase;
					TeHead->DataDirectory[EFI_TE_IMAGE_DIRECTORY_ENTRY_BASERELOC]=NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_BASERELOC];
					TeHead->DataDirectory[EFI_TE_IMAGE_DIRECTORY_ENTRY_DEBUG]=NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_DEBUG];
					// Throw warnings about unwanted data directories...
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_EXPORT].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Export.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_IMPORT].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Import.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_RESOURCE].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Resource. Please find .rsrc section when you make use of it!\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_EXCEPTION].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_EXCEPTION].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Exception.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_SECURITY].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_SECURITY].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Security.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_COPYRIGHT].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_COPYRIGHT].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Copyright.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_GLOBALPTR].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_GLOBALPTR].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Global Pointer.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_TLS].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_TLS].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Thread Local Storage.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Load Config.\n");
					break;
				}
				case EFI_IMAGE_NT_OPTIONAL_HDR64_MAGIC:
				{
					EFI_IMAGE_NT_HEADERS64* NtHead=&NtHeadUnion->Pe32Plus;
					TeHead->Subsystem=(UINT8)NtHead->OptionalHeader.Subsystem;
					TeHead->AddressOfEntryPoint=NtHead->OptionalHeader.AddressOfEntryPoint;
					TeHead->BaseOfCode=NtHead->OptionalHeader.BaseOfCode;
					TeHead->ImageBase=NtHead->OptionalHeader.ImageBase;
					TeHead->DataDirectory[EFI_TE_IMAGE_DIRECTORY_ENTRY_BASERELOC]=NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_BASERELOC];
					TeHead->DataDirectory[EFI_TE_IMAGE_DIRECTORY_ENTRY_DEBUG]=NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_DEBUG];
					// Throw warnings about unwanted data directories...
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_EXPORT].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Export.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_IMPORT].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Import.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_RESOURCE].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Resource. Please find .rsrc section when you make use of it!\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_EXCEPTION].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_EXCEPTION].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Exception.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_SECURITY].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_SECURITY].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Security.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_COPYRIGHT].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_COPYRIGHT].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Copyright.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_GLOBALPTR].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_GLOBALPTR].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Global Pointer.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_TLS].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_TLS].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Thread Local Storage.\n");
					if(NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG].VirtualAddress || NtHead->OptionalHeader.DataDirectory[EFI_IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG].Size)
						ConsolePrintfA("[Warning] Unwanted Data Directory is detected in NT Optional Header: Load Config.\n");
					break;
				}
				default:
				{
					ConsolePrintfA("Unknown Optional Header Magic: 0x%04X!\n",Magic);
					return FALSE;
				}
			}
			// Copy from File Header.
			TeHead->Machine=NtHeadUnion->Pe32.FileHeader.Machine;
			TeHead->NumberOfSections=(UINT8)NtHeadUnion->Pe32.FileHeader.NumberOfSections;
			// Initialize TE Header
			TeHead->Signature=EFI_TE_IMAGE_HEADER_SIGNATURE;
			TeHead->StrippedSize=PeHeaderSize-sizeof(EFI_TE_IMAGE_HEADER);
			ConsolePrintfA("Stripped Size: %u\n",TeHead->StrippedSize);
			// Initialize Section Header List
			for(UINT8 i=0;i<TeHead->NumberOfSections;i++)
			{
				for(UINTN j=0;j<EFI_IMAGE_SIZEOF_SHORT_NAME;j++)
					TeSections[i].Name[j]=PeSections[i].Name[j];
				TeSections[i].Misc=PeSections[i].Misc;
				TeSections[i].VirtualAddress=PeSections[i].VirtualAddress;
				TeSections[i].SizeOfRawData=PeSections[i].SizeOfRawData;
				TeSections[i].PointerToRawData=PeSections[i].PointerToRawData-TeHead->StrippedSize;
				TeSections[i].PointerToRelocations=PeSections[i].PointerToRelocations-TeHead->StrippedSize;
				TeSections[i].PointerToLinenumbers=PeSections[i].PointerToLinenumbers-TeHead->StrippedSize;
				TeSections[i].NumberOfRelocations=PeSections[i].NumberOfRelocations;
				TeSections[i].NumberOfLinenumbers=PeSections[i].NumberOfLinenumbers;
				TeSections[i].Characteristics=PeSections[i].Characteristics;
				// Copy the section.
				CopyMem((VOID*)((UINTN)TeImage+TeSections[i].VirtualAddress),(VOID*)((UINTN)PeImage+PeSections[i].VirtualAddress),PeSections[i].SizeOfRawData);
			}
		}
	}
	return FALSE;
}