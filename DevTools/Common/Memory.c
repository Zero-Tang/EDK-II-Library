#include <Windows.h>

extern HANDLE ProcHeap;

void CopyMem(OUT PVOID Destination,IN PVOID Source,IN SIZE_T Length)
{
	RtlCopyMemory(Destination,Source,Length);
}

LONG StringCompareA(IN PSTR String1,IN PSTR String2)
{
	SIZE_T i=0;
	while(String1[i]!=0 || String2[i]!=0)
	{
		if(String1[i]>String2[i])
			return 1;
		else if(String1[i]<String2[i])
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