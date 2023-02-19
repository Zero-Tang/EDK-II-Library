#include <Windows.h>
#include <Common.h>
#include "main.h"

BOOL ReadDumpMemory(IN ULONG64 Address,OUT PVOID Buffer,IN ULONG32 Size,OUT PULONG32 NumberOfBytesRead OPTIONAL)
{
	LARGE_INTEGER FilePtr;
	BOOL Result=FALSE;
	FilePtr.QuadPart=Address;
	Result=SetFilePointerEx(DumpFileHandle,FilePtr,NULL,FILE_BEGIN);
	if(Result)
	{
		DWORD dwRead;
		Result=ReadFile(DumpFileHandle,Buffer,Size,&dwRead,NULL);
		if(NumberOfBytesRead)*NumberOfBytesRead=dwRead;
	}
	return Result;
}

int main(int argc,char* argv[],char* envp[])
{
	PSTR FileName=NULL;
	Initialize();
	for(int i=1;i<argc;i++)
	{
		if(StringCompareA(argv[i],"/help")==0)
			ConsolePrintfA("Usage: %s <Path to Dump File>\n",*argv);
		else
			FileName=argv[i];
	}
	if(FileName==NULL)
	{
		ConsolePrintfA("No file was specified!");
		return 1;
	}
	else
	{
		DumpFileHandle=CreateFileA(FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
		if(DumpFileHandle==INVALID_HANDLE_VALUE)
		{
			ConsolePrintfA("Failed to open dump file! Error Code: %u\n",GetLastError());
			return 2;
		}
		else
		{
			StartDumpInterface();
			CloseHandle(DumpFileHandle);
			return 0;
		}
	}
	return 0;
}