@echo off
set edkpath=C:\UefiDKII
set mdepath=C:\UefiDKII\MdePkg
set binpath=C:\UefiDKII\Bin\MdePkg\compchk_uefix64
set objpath=C:\UefiDKII\Bin\MdePkg\compchk_uefix64\Intermediate

title Compiling EDK-II-Library, Checked Build, UEFI (AMD64 Architecture)
echo Project: EDK-II-Library, Checked Build
echo Platform: Unified Extensible Firmware Interface
echo Preset: Debug/Checked Build
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2020, zero.tangptr@gmail.com. All Rights Reserved.
clang-cl --version
lld-link --version
pause

echo Compiling BaseLib...
for %%1 in (%mdepath%\Library\BaseLib\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /Od /Oy- /Fa"%objpath%\BaseLib\%%~n1.cod" /Fo"%objpath%\BaseLib\%%~n1.obj" /FI"%mdepath%\Library\BaseLib\BaseLibInternals.h" /FI".\pcdhack.h" /GS- /Gr /TC /c)
for %%1 in (%mdepath%\Library\BaseLib\X64\*.nasm) do (nasm -o "%objpath%\BaseLib\%%~n1.obj" -fwin64 -g -I"%mdepath%\Library\BaseLib" -I"%mdepath%\Include" -I"%mdepath%\Include\X64" -P".\pcdhack.nasm" %%1)
llvm-lib "%objpath%\BaseLib\*.obj" /MACHINE:X64 /OUT:"%binpath%\BaseLib.Lib"

echo Compiling BaseDebugPrintErrorLevelLib...
clang-cl %mdepath%\Library\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /Od /Oy- /Fa"%objpath%\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.cod" /Fo"%objpath%\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.obj" /FI".\pcdhack.h" /GS- /Gr /TC /c
llvm-lib "%objpath%\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.obj" /MACHINE:X64 /OUT:"%binpath%\BaseDebugPrintErrorLevelLib.lib"

echo Compiling BaseMemoryLib...
for %%1 in (%mdepath%\Library\BaseMemoryLib\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /Od /Oy- /Fa"%objpath%\BaseMemoryLib\%%~n1.cod" /Fo"%objpath%\BaseMemoryLib\%%~n1.obj" /FI"%mdepath%\Library\BaseMemoryLib\MemLibInternals.h" /FI".\pcdhack.h" /GS- /Gr /TC /c)
llvm-lib "%objpath%\BaseMemoryLib\*.obj" /MACHINE:X64 /OUT:"%binpath%\BaseMemoryLib.Lib"

echo Compiling BasePrintLib...
for %%1 in (%mdepath%\Library\BasePrintLib\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /Od /Oy- /Fa"%objpath%\BasePrintLib\%%~n1.cod" /Fo"%objpath%\BasePrintLib\%%~n1.obj" /FI".\pcdhack.h" /GS- /Gr /TC /c)
llvm-lib "%objpath%\BasePrintLib\*.obj" /MACHINE:X64 /OUT:"%binpath%\BasePrintLib.Lib"

echo Compiling UefiBootServicesTableLib...
clang-cl %mdepath%\Library\UefiBootServicesTableLib\UefiBootServicesTableLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /Od /Oy- /Fa"%objpath%\UefiBootServicesTableLib\UefiBootServicesTableLib.cod" /Fo"%objpath%\UefiBootServicesTableLib\UefiBootServicesTableLib.obj" /FI".\pcdhack.h" /GS- /Gr /TC /c
llvm-lib "%objpath%\UefiBootServicesTableLib\UefiBootServicesTableLib.obj" /MACHINE:X64 /OUT:"%binpath%\UefiBootServicesTableLib.Lib"

echo Compiling UefiRuntimeServicesTableLib...
clang-cl %mdepath%\Library\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /Od /Oy- /Fa"%objpath%\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.cod" /Fo"%objpath%\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.obj" /FI".\pcdhack.h" /GS- /Gr /TC /c
llvm-lib "%objpath%\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.obj" /MACHINE:X64 /OUT:"%binpath%\UefiRuntimeServicesTableLib.Lib"

echo Compiling UefiDevicePathLibDevicePathProtocol...
clang-cl %mdepath%\Library\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /Od /Oy- /Fa"%objpath%\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.cod" /Fo"%objpath%\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.obj" /FI".\pcdhack.h" /GS- /Gr /TC /c
llvm-lib "%objpath%\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.obj" /MACHINE:X64 /OUT:"%binpath%\UefiDevicePathLib.Lib"

echo Compiling UefiLib...
for %%1 in (%mdepath%\Library\UefiLib\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /Od /Oy- /Fa"%objpath%\UefiLib\%%~n1.cod" /Fo"%objpath%\UefiLib\%%~n1.obj" /FI".\pcdhack.h" /GS- /Gr /TC /c)
llvm-lib "%objpath%\UefiLib\*.obj" /MACHINE:X64 /OUT:"%binpath%\UefiLib.Lib"
 
echo Compiling UefiDebugLibConOut...
for %%1 in (%mdepath%\Library\UefiDebugLibConOut\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /Od /Oy- /Fa"%objpath%\UefiDebugLibConOut\%%~n1.cod" /Fo"%objpath%\UefiDebugLibConOut\%%~n1.obj" /FI".\pcdhack.h" /GS- /Gr /TC /c)
llvm-lib "%objpath%\UefiDebugLibConOut\*.obj" /MACHINE:X64 /OUT:"%binpath%\UefiDebugLibConOut.Lib"

echo Compiling UefiMemoryAllocationLib...
clang-cl %mdepath%\Library\UefiMemoryAllocationLib\MemoryAllocationLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /Od /Oy- /Fa"%objpath%\UefiMemoryAllocationLib\MemoryAllocationLib.cod" /Fo"%objpath%\UefiMemoryAllocationLib\MemoryAllocationLib.obj" /FI".\pcdhack.h" /GS- /Gr /TC /c
llvm-lib "%objpath%\UefiMemoryAllocationLib\MemoryAllocationLib.obj" /MACHINE:X64 /OUT:"%binpath%\UefiMemoryAllocationLib.lib"

echo Completed!
pause.