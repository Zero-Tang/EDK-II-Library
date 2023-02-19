#pragma once

#define NumberOfDefinedCommands		2

typedef BOOL (*COMMAND_PROCESSOR)
(
	IN ULONG NumberOfParameters,
	IN PSTR Parameters[]
);

BOOL ReadDumpMemory(IN ULONG64 Address,OUT PVOID Buffer,IN ULONG32 Size,OUT PULONG32 NumberOfBytesRead OPTIONAL);

// Command Processors...
BOOL DefaultCommandProcessor(IN ULONG NumberOfParameters,IN PSTR Parameters[]);
BOOL QuitCommandProcessor(IN ULONG NumberOfParameters,IN PSTR Parameters[]);

// This must be a sorted list in order to accelerate the command processing through binary search.
PSTR CommandList[NumberOfDefinedCommands]=
{
	"list-image",
	"quit"
};

COMMAND_PROCESSOR CommandProcessors[NumberOfDefinedCommands]=
{
	DefaultCommandProcessor,
	QuitCommandProcessor
};