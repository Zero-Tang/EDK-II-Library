@echo off
set edkpath=C:\UefiDKII
set mdepath=C:\UefiDKII\MdePkg
set mmppath=C:\UefiDKII\MdeModulePkg
set binpath=C:\UefiDKII\Bin\MdeModulePkg\compchk_uefix64
set objpath=C:\UefiDKII\Bin\MdeModulePkg\compchk_uefix64\Intermediate

title Compiling EDK-II-Library MdeModulePkg, Checked Build, UEFI (AMD64 Architecture)
echo Project: EDK-II-Library MdeModulePkg, Checked Build
echo Platform: Unified Extensible Firmware Interface
echo Preset: Debug/Checked Build
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2020-2022, zero.tangptr@gmail.com. All Rights Reserved.
clang-cl --version
lld-link --version
pause

echo Compiling RuntimeDxeCore...
for %%1 in (%mmppath%\Core\RuntimeDxe\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I"%mmppath%\Include" /Zi /W3 /WX /Od /Oi /Fa"%objpath%\RuntimeDxeCore\%%~n1.cod" /Fo"%objpath%\RuntimeDxeCore\%%~n1.obj" /GS- /Gr /TC /c -Wno-microsoft-static-assert)
llvm-lib "%objpath%\RuntimeDxeCore\*.obj" /MACHINE:X64 /OUT:"%binpath%\RuntimeDxeCore.lib"

echo Compiling UefiSortLib...
clang-cl %mmppath%\Library\UefiSortLib\UefiSortLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I"%mmppath%\Include" /Zi /W3 /WX /Od /Oi /Fa"%objpath%\UefiSortLib\UefiSortLib.cod" /Fo"%objpath%\UefiSortLib\UefiSortLib.obj" /GS- /Gr /TC /c -Wno-microsoft-static-assert
llvm-lib "%objpath%\UefiSortLib\UefiSortLib.obj" /MACHINE:X64 /OUT:"%binpath%\UefiSortLib.lib"

echo Completed!
pause.