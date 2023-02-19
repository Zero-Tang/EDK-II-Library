#include <Windows.h>
#include <strsafe.h>
#include <stdarg.h>
#include <Common.h>
#include "main.h"

PVOID LoadPeImage(IN PSTR FilePath,OUT PULONG32 ImageSize OPTIONAL)
{
	HANDLE hFile=CreateFileA(FilePath,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
	PVOID PeImage=NULL;
	if(hFile==INVALID_HANDLE_VALUE)
		ConsolePrintfA("Failed to open image file! Error Code=%u\n",GetLastError());
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
				ConsolePrintfA("NT Signature Mismatch!\n");
		}
		else
			ConsolePrintfA("DOS Signature Mismatch!\n");
		CloseHandle(hFile);
	}
	return PeImage;
}

BOOL CommitTeImage(IN PSTR FilePath,IN PVOID TeImage)
{
	HANDLE hFile=CreateFileA(FilePath,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL);
	if(hFile==INVALID_HANDLE_VALUE)
	{
		ConsolePrintfA("Failed to create TE Image! Error Code: %u\n",GetLastError());
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
				ConsolePrintfA("Error: Unknown option \"%s\"!",argv[i]);
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
		ConsolePrintfA("Error: You did not specify the input image!\n");
		return 1;
	}
	if(OutputFilePath==NULL)
	{
		ConsolePrintfA("Error: You did not specify the output image!\n");
		return 1;
	}
	ConsolePrintfA("You are converting input image into a %s image!\n",ConvertToTE?"TE":"PE");
	PeImageBase=LoadPeImage(InputFilePath,&PeImageSize);
	if(PeImageBase)
	{
		TeImageBase=PageAlloc(PeImageSize);
		if(TeImageBase)
		{
			ConsolePrintfA("Converting to TE image...\n");
			ConvertToTerseExecutableImage(PeImageBase,TeImageBase);
			ConsolePrintfA("Committing TE image...\n");
			CommitTeImage(OutputFilePath,TeImageBase);
			PageFree(TeImageBase);
		}
		PageFree(PeImageBase);
	}
	return 0;
}