#include <Windows.h>
#include <strsafe.h>
#include <stdarg.h>
#include "main.h"

ULONG ConsolePrintA(IN PCSTR Format,...)
{
	CHAR Buffer[512];
	va_list ArgList;
	SIZE_T StringLength;
	ULONG PrintedLength;
	va_start(ArgList,Format);
	StringCbVPrintfA(Buffer,sizeof(Buffer),Format,ArgList);
	StringCbLengthA(Buffer,sizeof(Buffer),&StringLength);
	WriteConsoleA(StdOut,Buffer,(ULONG)StringLength,&PrintedLength,NULL);
	va_end(ArgList);
	return PrintedLength;
}

void CopyMem(OUT PVOID Destination,IN PVOID Source,IN SIZE_T Length)
{
	RtlCopyMemory(Destination,Source,Length);
}

LONG StringCompareA(IN PSTR String1,IN PSTR String2)
{
	SIZE_T i=0;
	while(String1[i]!=0 && String2[i]!=0)
	{
		if(String1[i]>String2[i])
			return 1;
		else if(String1[i]<String2[2])
			return -1;
		i++;
	}
	return 0;
}

PVOID MemAlloc(IN SIZE_T Length)
{
	return HeapAlloc(ProcHeap,HEAP_ZERO_MEMORY,Length);
}

BOOL MemFree(IN PVOID Memory)
{
	return HeapFree(ProcHeap,0,Memory);
}

PVOID PageAlloc(IN SIZE_T Length)
{
	PVOID p=VirtualAlloc(NULL,Length,MEM_COMMIT,PAGE_READWRITE);
	if(p)RtlZeroMemory(p,Length);
	return p;
}

BOOL PageFree(IN PVOID Memory)
{
	return VirtualFree(Memory,0,MEM_RELEASE);
}

PVOID LoadPeImage(IN PSTR FilePath,OUT PULONG32 ImageSize OPTIONAL)
{
	HANDLE hFile=CreateFileA(FilePath,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
	PVOID PeImage=NULL;
	if(hFile==INVALID_HANDLE_VALUE)
		ConsolePrintA("Failed to open image file! Error Code=%u\n",GetLastError());
	else
	{
		DWORD dwRead;
		IMAGE_DOS_HEADER DosHead;
		SetFilePointer(hFile,0,NULL,FILE_BEGIN);
		ReadFile(hFile,&DosHead,sizeof(DosHead),&dwRead,NULL);
		if(DosHead.e_magic==IMAGE_DOS_SIGNATURE)
		{
			IMAGE_NT_HEADERS64 NtHead;
			SetFilePointer(hFile,DosHead.e_lfanew,NULL,FILE_BEGIN);
			ReadFile(hFile,&NtHead,sizeof(NtHead),&dwRead,NULL);
			if(NtHead.Signature==IMAGE_NT_SIGNATURE)
			{
				SIZE_T NtHeadSize=sizeof(NtHead);
				ULONG SizeOfImage=0;
				const SIZE_T SectionTableSize=sizeof(IMAGE_SECTION_HEADER)*NtHead.FileHeader.NumberOfSections;
				switch(NtHead.OptionalHeader.Magic)
				{
					case IMAGE_NT_OPTIONAL_HDR32_MAGIC:
					{
						PIMAGE_NT_HEADERS32 NtHead32=(PIMAGE_NT_HEADERS32)&NtHead;
						NtHeadSize=sizeof(IMAGE_NT_HEADERS32);
						SizeOfImage=NtHead32->OptionalHeader.SizeOfImage;
						break;
					}
					case IMAGE_NT_OPTIONAL_HDR64_MAGIC:
					{
						SizeOfImage=NtHead.OptionalHeader.SizeOfImage;
						break;
					}
					case IMAGE_ROM_OPTIONAL_HDR_MAGIC:
					{
						PIMAGE_ROM_HEADERS RomHead=(PIMAGE_ROM_HEADERS)&NtHead;
						NtHeadSize=sizeof(IMAGE_ROM_HEADERS);
						break;
					}
					default:
					{
						break;
					}
				}
				if(ImageSize)*ImageSize=SizeOfImage;
				PeImage=PageAlloc(SizeOfImage);
				if(PeImage)
				{
					PIMAGE_SECTION_HEADER SectionHeaders=(PVOID)((ULONG_PTR)PeImage+DosHead.e_lfanew+NtHeadSize);
					RtlCopyMemory(PeImage,&DosHead,sizeof(DosHead));
					RtlCopyMemory((PVOID)((ULONG_PTR)PeImage+DosHead.e_lfanew),&NtHead,NtHeadSize);
					SetFilePointer(hFile,(ULONG)(DosHead.e_lfanew+NtHeadSize),NULL,FILE_BEGIN);
					ReadFile(hFile,SectionHeaders,(ULONG)SectionTableSize,&dwRead,NULL);
					for(USHORT i=0;i<NtHead.FileHeader.NumberOfSections;i++)
					{
						PVOID Section=(PVOID)((ULONG_PTR)PeImage+SectionHeaders[i].VirtualAddress);
						SetFilePointer(hFile,SectionHeaders[i].PointerToRawData,NULL,FILE_BEGIN);
						ReadFile(hFile,Section,SectionHeaders[i].SizeOfRawData,&dwRead,NULL);
					}
				}
			}
			else
				ConsolePrintA("NT Signature Mismatch!\n");
		}
		else
			ConsolePrintA("DOS Signature Mismatch!\n");
		CloseHandle(hFile);
	}
	return PeImage;
}

BOOL CommitTeImage(IN PSTR FilePath,IN PVOID TeImage)
{
	HANDLE hFile=CreateFileA(FilePath,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL);
	if(hFile==INVALID_HANDLE_VALUE)
	{
		ConsolePrintA("Failed to create TE Image! Error Code: %u\n",GetLastError());
		return FALSE;
	}
	else
	{
		LONG i=-1;
		while(1)
		{
			DWORD dwWrite;
			ULONG32 SectionSize,FileOffset;
			PVOID TeSection=GetTeImageSection(TeImage,i++,&SectionSize,&FileOffset);
			if(TeSection==NULL)break;
			SetFilePointer(hFile,FileOffset,NULL,FILE_BEGIN);
			WriteFile(hFile,TeSection,SectionSize,&dwWrite,NULL);
		}
		CloseHandle(hFile);
		return TRUE;
	}
}

void Initialize()
{
	StdIn=GetStdHandle(STD_INPUT_HANDLE);
	StdOut=GetStdHandle(STD_OUTPUT_HANDLE);
	StdErr=GetStdHandle(STD_ERROR_HANDLE);
	ProcHeap=GetProcessHeap();
}

int main(int argc,char* argv[],char* envp[])
{
	BOOLEAN ConvertToTE=TRUE;
	PSTR InputFilePath=NULL,OutputFilePath=NULL;
	PVOID PeImageBase=NULL,TeImageBase=NULL;
	ULONG PeImageSize=0,TeImageSize=0;
	Initialize();
	if(argc==1)
	{
		// Print help text.
		return 1;
	}
	for(int i=0;i<argc;i++)
	{
		if(*argv[i]=='/' || *argv[i]=='-')
		{
			if(argv[i][2])
			{
				ConsolePrintA("Error: Unknown option \"%s\"!",argv[i]);
				return 1;
			}
			switch(argv[i][1])
			{
				case 'o':
				{
					OutputFilePath=argv[++i];
					break;
				}
				case 'p':
				{
					ConvertToTE=FALSE;
					break;
				}
				case 't':
				{
					ConvertToTE=TRUE;
					break;
				}
			}
		}
		else
			InputFilePath=argv[i];
	}
	if(InputFilePath==NULL)
	{
		ConsolePrintA("Error: You did not specify the input image!\n");
		return 1;
	}
	if(OutputFilePath==NULL)
	{
		ConsolePrintA("Error: You did not specify the output image!\n");
		return 1;
	}
	ConsolePrintA("You are converting input image into a %s image!\n",ConvertToTE?"TE":"PE");
	PeImageBase=LoadPeImage(InputFilePath,&PeImageSize);
	if(PeImageBase)
	{
		TeImageBase=PageAlloc(PeImageSize);
		if(TeImageBase)
		{
			ConsolePrintA("Converting to TE image...\n");
			ConvertToTerseExecutableImage(PeImageBase,TeImageBase);
			ConsolePrintA("Committing TE image...\n");
			CommitTeImage(OutputFilePath,TeImageBase);
			PageFree(TeImageBase);
		}
		PageFree(PeImageBase);
	}
	return 0;
}