#pragma once

UINT32 ConsolePrintfA(IN CONST CHAR8 *Format,...);
VOID* MemAlloc(IN UINTN Length);
BOOLEAN MemFree(IN VOID* Memory);
BOOLEAN ReadDumpMemory(IN UINT64 Address,OUT VOID* Buffer,IN UINT32 Size,OUT UINT32 *NumberOfBytesRead OPTIONAL);

extern UINT64 DumpFileSize;

EFI_GUID gEfiDebugImageInfoTableGuid=EFI_DEBUG_IMAGE_INFO_TABLE_GUID;