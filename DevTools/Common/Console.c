#include <Windows.h>
#include <strsafe.h>
#include <stdarg.h>
#include <Common.h>

ULONG ConsoleVPrintfA(IN PCSTR Format,IN va_list ArgList)
{
	CHAR Buffer[512];
	SIZE_T StringLength;
	ULONG PrintedLength;
	StringCbVPrintfA(Buffer,sizeof(Buffer),Format,ArgList);
	StringCbLengthA(Buffer,sizeof(Buffer),&StringLength);
	WriteConsoleA(StdOut,Buffer,(ULONG)StringLength,&PrintedLength,NULL);
	return PrintedLength;
}

ULONG ConsolePrintfA(IN PCSTR Format,...)
{
	va_list ArgList;
	ULONG PrintedLength;
	va_start(ArgList,Format);
	PrintedLength=ConsoleVPrintfA(Format,ArgList);
	va_end(ArgList);
	return PrintedLength;
}