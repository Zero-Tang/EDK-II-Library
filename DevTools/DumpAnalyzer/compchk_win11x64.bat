@echo off
set edkpath=%EDK2_PATH%\edk2
set ddkpath=V:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.31.31103
set path=%ddkpath%\bin\Hostx64\x64;V:\Program Files\Windows Kits\10\bin\10.0.22621.0\x64;%path%
set incpath=V:\Program Files\Windows Kits\10\Include\10.0.22621.0
set libpath=V:\Program Files\Windows Kits\10\Lib\10.0.22621.0
set dbgpath=V:\Program Files\Windows Kits\10\Debuggers
set binpath=..\bin\compchk_win11x64
set objpath=..\bin\compchk_win11x64\Intermediate\PE2TE

title Compiling DumpAnalyzer, Checked Build, 64-Bit Windows (AMD64 Architecture)
echo Project: EFI Dump Analyzer
echo Platform: 64-Bit Windows
echo Preset: Debug/Checked Build
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2022, zero.tangptr@gmail.com. All Rights Reserved.
if "%~1"=="/s" (echo DO-NOT-PAUSE is activated!) else (pause)

echo ============Start Compiling============
cl .\main.c /I"%incpath%\shared" /I"%incpath%\um" /I"%incpath%\ucrt" /I"%ddkpath%\include" /I"..\Include" /Zi /nologo /W3 /WX /Od /Oi /D"_AMD64_" /D"_M_AMD64" /D"_WIN64" /D"_UNICODE" /D"UNICODE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\main.cod" /Fo"%objpath%\main.obj" /Fd"%objpath%\vc140.pdb" /GS- /Qspectre /TC /c /errorReport:queue

cl .\interface.c /I"%incpath%\shared" /I"%incpath%\um" /I"%incpath%\ucrt" /I"%ddkpath%\include" /I"%dbgpath%\inc" /I"..\Include" /Zi /nologo /W3 /WX /Od /Oi /D"_AMD64_" /D"_M_AMD64" /D"_WIN64" /D"_UNICODE" /D"UNICODE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\interface.cod" /Fo"%objpath%\interface.obj" /Fd"%objpath%\vc140.pdb" /GS- /Qspectre /TC /c /errorReport:queue

cl .\parser.c /I"%edkpath%\MdePkg\Include" /I"%edkpath%\MdePkg\Include\X64" /Zi /nologo /W3 /WX /Od /Oi /D"_AMD64_" /D"_M_AMD64" /D"_WIN64" /D"_UNICODE" /D "UNICODE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\parser.cod" /Fo"%objpath%\parser.obj" /Fd"%objpath%\vc140.pdb" /GS- /Qspectre /TC /c /errorReport:queue

echo ============Start Linking============
link "%objpath%\*.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x64" /LIBPATH:"%libpath%\ucrt\x64" /LIBPATH:"%ddkpath%\lib\x64" /LIBPATH:"%dbgpath%\lib\x64" "dbghelp.lib" /NOLOGO /DEBUG /INCREMENTAL:NO /PDB:"%objpath%\DumpAnalyzer.pdb" /OUT:"%binpath%\DumpAnalyzer.exe" /SUBSYSTEM:CONSOLE /Machine:X64 /ERRORREPORT:QUEUE

if "%~1"=="/s" (echo Completed!) else (pause)