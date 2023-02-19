#include <Windows.h>
#include <strsafe.h>
#include <Common.h>
#include "interface.h"

ULONG GetCommand(IN PSTR CommandString,IN SIZE_T MaximumLength,OUT PSTR **Parameters)
{
	SIZE_T StringLength=0;
	BOOL InSpace=TRUE;
	ULONG NumberOfParameters=0;
	SIZE_T ParameterOffsets[16];
	// Stage I: Count the number of parameters by splitting the string.
	for(ULONG i=0;i<MaximumLength;i++)
	{
		if(CommandString[i]=='\0')
		{
			if(!InSpace)NumberOfParameters++;
			break;
		}
		StringLength++;
		if(CommandString[i]==' ')
		{
			if(!InSpace)NumberOfParameters++;
			if(NumberOfParameters>=16)
			{
				ConsolePrintfA("More than 16 parameters are found!\n");
				return 0;
			}
			CommandString[i]='\0';
			InSpace=TRUE;
		}
		else
		{
			if(InSpace)ParameterOffsets[NumberOfParameters]=i;
			InSpace=FALSE;
		}
	}
	// Stage II: Initialize the return array of parameters.
	*Parameters=MemAlloc(sizeof(PSTR)*NumberOfParameters);
	for(ULONG i=0;i<NumberOfParameters;i++)
		(*Parameters)[i]=&CommandString[ParameterOffsets[i]];
	return NumberOfParameters;
}

void StartDumpInterface()
{
	BOOL ContinueInterface=TRUE;
	ConsolePrintfA("Welcome to EFI Dump Analyzer Interface!\n");
	ConsolePrintfA("Copyright (c) 2023 Zero Tang. All rights reserved.\n");
	while(ContinueInterface)
	{
		COMMAND_PROCESSOR ProcessCommand=NULL;
		CHAR CmdBuff[128];
		PSTR CmdString=NULL;
		PSTR *ParamArray=NULL;
		ULONG ParamCount=0;
		LONG Min=0,Max=NumberOfDefinedCommands-1;
		ConsolePrintfA("$");
		// Get the command string from console.
		StringCbGetsA(CmdBuff,sizeof(CmdBuff));
		// Parse the command string and split into parameters.
		ParamCount=GetCommand(CmdBuff,sizeof(CmdBuff),&ParamArray);
		if(IsDebuggerPresent())__debugbreak();
		// Use Binary-Search to invoke the proper command.
		while(Max>=Min)
		{
			LONG Mid=(Min+Max)>>1;
			LONG Comparison=StringCompareA(CommandList[Mid],*ParamArray);
			if(Comparison<0)
				Min=Mid+1;
			else if(Comparison>0)
				Max=Mid-1;
			else
			{
				ProcessCommand=CommandProcessors[Mid];
				break;
			}
		}
		if(ProcessCommand)
			ContinueInterface=ProcessCommand(ParamCount,ParamArray);
		else
			ConsolePrintfA("Unknown Command: %s!\n",*ParamArray);
		// Clean up.
		MemFree(ParamArray);
	} 
	ConsolePrintfA("Stopping Dump Interface...\n");
}

BOOL DefaultCommandProcessor(IN ULONG NumberOfParameters,IN PSTR Parameters[])
{
	ConsolePrintfA("Unimplemented Command: %s!\n",*Parameters);
	return TRUE;
}

BOOL QuitCommandProcessor(IN ULONG NumberOfParameters,IN PSTR Parameters[])
{
	return FALSE;
}