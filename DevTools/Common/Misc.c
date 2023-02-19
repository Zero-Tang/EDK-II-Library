#include <Windows.h>

HANDLE StdIn=INVALID_HANDLE_VALUE;
HANDLE StdOut=INVALID_HANDLE_VALUE;
HANDLE StdErr=INVALID_HANDLE_VALUE;
HANDLE ProcHeap=NULL;

void Initialize()
{
	StdIn=GetStdHandle(STD_INPUT_HANDLE);
	StdOut=GetStdHandle(STD_OUTPUT_HANDLE);
	StdErr=GetStdHandle(STD_ERROR_HANDLE);
	ProcHeap=GetProcessHeap();
}