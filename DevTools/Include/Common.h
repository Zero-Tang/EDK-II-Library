#pragma once

extern HANDLE StdIn;
extern HANDLE StdOut;
extern HANDLE StdErr;
extern HANDLE ProcHeap;

// Console Functions...
ULONG ConsolePrintfA(IN PCSTR Format,...);
ULONG ConsoleVPrintfA(IN PCSTR Format,IN va_list ArgList);

// Memory Management Functions...
void CopyMem(OUT PVOID Destination,IN PVOID Source,IN SIZE_T Length);
PVOID MemAlloc(IN SIZE_T Length);
BOOL MemFree(IN PVOID Memory);
PVOID PageAlloc(IN SIZE_T Length);
BOOL PageFree(IN PVOID Memory);
LONG StringCompareA(IN PSTR String1,IN PSTR String2);

// Initialization Routine...
void Initialize();