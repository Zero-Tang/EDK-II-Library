@echo off
set edkpath=C:\UefiDKII
set mdepath=C:\UefiDKII\MdePkg
set cpupath=C:\UefiDKII\UefiCpuPkg
set sldpath=C:\UefiDKII\SourceLevelDebugPkg
set binpath=C:\UefiDKII\Bin\SourceLevelDebugPkg\compchk_uefix64
set objpath=C:\UefiDKII\Bin\SourceLevelDebugPkg\compchk_uefix64\Intermediate

title Compiling EDK-II-Library SourceLevelDebugPkg, Checked Build, UEFI (AMD64 Architecture)
echo Project: EDK-II-Library SourceLevelDebugPkg, Checked Build
echo Platform: Unified Extensible Firmware Interface
echo Preset: Debug/Checked Build
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2020-2022, zero.tangptr@gmail.com. All Rights Reserved.
clang-cl --version
lld-link --version
pause

echo Compiling SourceLevelDebugPkg.DebugAgent ...
for %%1 in (%sldpath%\Library\DebugAgent\DebugAgentCommon\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I"%sldpath%\Include" /I"%cpupath%\Include" /Zi /W3 /WX /Od /Oi /Fa"%objpath%\DebugAgent\%%~n1.cod" /Fo"%objpath%\DebugAgent\%%~n1.obj" /GS- /Gr /TC /c -Wno-microsoft-static-assert)
clang-cl %sldpath%\Library\DebugAgent\DebugAgentCommon\X64\ArchDebugSupport.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I"%sldpath%\Include" /I"%cpupath%\Include" /Zi /W3 /WX /Od /Oi /Fa"%objpath%\DebugAgent\ArchiDebugSupport.cod" /Fo"%objpath%\DebugAgent\ArchDebugSupport.obj" /GS- /Gr /TC /c -Wno-microsoft-static-assert
llvm-lib "%objpath%\DebugAgent\*.obj" /MACHINE:X64 /OUT:"%binpath%\DebugAgent.lib"

echo Completed!
pause.