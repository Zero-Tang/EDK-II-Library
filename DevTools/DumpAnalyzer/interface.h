#pragma once

typedef struct _LOADED_IMAGE_NODE
{
	struct _LOADED_IMAGE_NODE* Next;
	ULONG64 ImageBase;
	ULONG64 ImageSize;
	WCHAR PdbFile[256];
}LOADED_IMAGE_NODE,*PLOADED_IMAGE_NODE;

#define NumberOfDefinedCommands		4

typedef BOOL (*COMMAND_PROCESSOR)
(
	IN ULONG NumberOfParameters,
	IN PSTR Parameters[]
);

BOOL ReadDumpMemory(IN ULONG64 Address,OUT PVOID Buffer,IN ULONG32 Size,OUT PULONG32 NumberOfBytesRead OPTIONAL);
void EnumerateImages();

// Command Processors...
BOOL DefaultCommandProcessor(IN ULONG NumberOfParameters,IN PSTR Parameters[]);
BOOL ListImageCommandProcessor(IN ULONG NumberOfParameters,IN PSTR Parameters[]);
BOOL QuitCommandProcessor(IN ULONG NumberOfParameters,IN PSTR Parameters[]);

// This must be a sorted list in order to accelerate the command processing through binary search.
PSTR CommandList[NumberOfDefinedCommands]=
{
	"dump",
	"disasm",
	"list-image",
	"quit"
};

COMMAND_PROCESSOR CommandProcessors[NumberOfDefinedCommands]=
{
	DefaultCommandProcessor,
	DefaultCommandProcessor,
	ListImageCommandProcessor,
	QuitCommandProcessor
};