@echo off
set edkpath=C:\UefiDKII
set mdepath=C:\UefiDKII\MdePkg
set mmppath=C:\UefiDKII\MdeModulePkg
set binpath=C:\UefiDKII\Bin\MdeModulePkg\compfre_uefix64
set objpath=C:\UefiDKII\Bin\MdeModulePkg\compfre_uefix64\Intermediate

title Compiling EDK-II-Library MdeModulePkg, Free Build, UEFI (AMD64 Architecture)
echo Project: EDK-II-Library MdeModulePkg, Free Build
echo Platform: Unified Extensible Firmware Interface
echo Preset: Release/Free Build
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2020, zero.tangptr@gmail.com. All Rights Reserved.
clang-cl --version
lld-link --version
pause

echo Compiling RuntimeDxeCore...
for %%1 in (%mmppath%\Core\RuntimeDxe\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I"%mmppath%\Include" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\RuntimeDxeCore\%%~n1.cod" /Fo"%objpath%\RuntimeDxeCore\%%~n1.obj" /GS- /Gy /GF /Gr /TC /c)
llvm-lib "%objpath%\RuntimeDxeCore\*.obj" /MACHINE:X64 /OUT:"%binpath%\RuntimeDxeCore.lib"

echo Compiling UefiSortLib...
clang-cl %mmppath%\Library\UefiSortLib\UefiSortLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I"%mmppath%\Include" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\UefiSortLib\UefiSortLib.cod" /Fo"%objpath%\UefiSortLib\UefiSortLib.obj" /GS- /Gy /GF /Gr /TC /c
llvm-lib "%objpath%\UefiSortLib\UefiSortLib.obj" /MACHINE:X64 /OUT:"%binpath%\UefiSortLib.lib"

echo Completed!
pause.