@echo off
set edkpath=..\edk2
set mdepath=..\edk2\MdePkg
set binpath=..\edk2\Bin\MdePkg\compfre_uefix64
set objpath=..\edk2\Bin\MdePkg\compfre_uefix64\Intermediate

title Compiling EDK-II-Library, Free Build, UEFI (AMD64 Architecture)
echo Project: EDK-II-Library, Free Build
echo Platform: Unified Extensible Firmware Interface
echo Preset: Release/Free Build
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2020-2022, zero.tangptr@gmail.com. All Rights Reserved.
clang-cl --version
lld-link --version
pause

echo Compiling BaseLib...
for %%1 in (%mdepath%\Library\BaseLib\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I"%mdepath%\Test\UnitTest\Include" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\BaseLib\%%~n1.cod" /Fo"%objpath%\BaseLib\%%~n1.obj" /FI"%mdepath%\Library\BaseLib\BaseLibInternals.h" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert)
del %objpath%\BaseLib\X86UnitTestHost.obj
for %%1 in (%mdepath%\Library\BaseLib\X64\*.nasm) do (nasm -o "%objpath%\BaseLib\%%~n1.obj" -fwin64 -g -I"%mdepath%\Library\BaseLib" -I"%mdepath%\Include" -I"%mdepath%\Include\X64" -P".\pcdhack.nasm" %%1)
llvm-lib "%objpath%\BaseLib\*.obj" /MACHINE:X64 /OUT:"%binpath%\BaseLib.Lib"

echo Compiling BaseDebugPrintErrorLevelLib...
clang-cl %mdepath%\Library\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.cod" /Fo"%objpath%\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.obj" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert
llvm-lib "%objpath%\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.obj" /MACHINE:X64 /OUT:"%binpath%\BaseDebugPrintErrorLevelLib.lib"

echo Compiling BaseIoLibIntrinsic...
clang-cl %mdepath%\Library\BaseIoLibIntrinsic\IoLibMsc.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\BaseIoLibIntrinsic\IoLibMsc.cod" /Fo"%objpath%\BaseIoLibIntrinsic\IoLibMsc.obj" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert -Wno-ignored-pragma-intrinsic -Wno-unused-value
clang-cl %mdepath%\Library\BaseIoLibIntrinsic\IoLibMmioBuffer.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\BaseIoLibIntrinsic\IoLibMmIoBuffer.cod" /Fo"%objpath%\BaseIoLibIntrinsic\IoLibMmioBuffer.obj" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert -Wno-ignored-pragma-intrinsic
clang-cl %mdepath%\Library\BaseIoLibIntrinsic\IoLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\BaseIoLibIntrinsic\IoLib.cod" /Fo"%objpath%\BaseIoLibIntrinsic\IoLib.obj" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert -Wno-ignored-pragma-intrinsic
clang-cl %mdepath%\Library\BaseIoLibIntrinsic\IoLibInternalTdxNull.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\BaseIoLibIntrinsic\IoLibInternalTdxNull.cod" /Fo"%objpath%\BaseIoLibIntrinsic\IoLibInternalTdxNull.obj" /FI".\pcdhack.h" /FI"Uefi.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert -Wno-ignored-pragma-intrinsic
for %%1 in (%mdepath%\Library\BaseIoLibIntrinsic\*.nasm) do (nasm -o "%objpath%\BaseIoLibIntrinsic\%%~n1.obj" -fwin64 -g -I"%mdepath%\Include" -I"%mdepath%\Include\X64" %%1)
llvm-lib "%objpath%\BaseIoLibIntrinsic\*.obj" /MACHINE:X64 /OUT:"%binpath%\BaseIoLibIntrinsic.Lib"

echo Compiling BaseMemoryLib...
for %%1 in (%mdepath%\Library\BaseMemoryLib\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\BaseMemoryLib\%%~n1.cod" /Fo"%objpath%\BaseMemoryLib\%%~n1.obj" /FI"%mdepath%\Library\BaseMemoryLib\MemLibInternals.h" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert)
llvm-lib "%objpath%\BaseMemoryLib\*.obj" /MACHINE:X64 /OUT:"%binpath%\BaseMemoryLib.Lib"

echo Compiling BasePrintLib...
for %%1 in (%mdepath%\Library\BasePrintLib\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\BasePrintLib\%%~n1.cod" /Fo"%objpath%\BasePrintLib\%%~n1.obj" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert)
llvm-lib "%objpath%\BasePrintLib\*.obj" /MACHINE:X64 /OUT:"%binpath%\BasePrintLib.Lib"

echo Compiling UefiBootServicesTableLib...
clang-cl %mdepath%\Library\UefiBootServicesTableLib\UefiBootServicesTableLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\UefiBootServicesTableLib\UefiBootServicesTableLib.cod" /Fo"%objpath%\UefiBootServicesTableLib\UefiBootServicesTableLib.obj" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert
llvm-lib "%objpath%\UefiBootServicesTableLib\UefiBootServicesTableLib.obj" /MACHINE:X64 /OUT:"%binpath%\UefiBootServicesTableLib.Lib"

echo Compiling UefiRuntimeServicesTableLib...
clang-cl %mdepath%\Library\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.cod" /Fo"%objpath%\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.obj" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert
llvm-lib "%objpath%\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.obj" /MACHINE:X64 /OUT:"%binpath%\UefiRuntimeServicesTableLib.Lib"

echo Compiling UefiDevicePathLibDevicePathProtocol...
clang-cl %mdepath%\Library\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.cod" /Fo"%objpath%\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.obj" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert
llvm-lib "%objpath%\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.obj" /MACHINE:X64 /OUT:"%binpath%\UefiDevicePathLib.Lib"

echo Compiling UefiLib...
for %%1 in (%mdepath%\Library\UefiLib\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\UefiLib\%%~n1.cod" /Fo"%objpath%\UefiLib\%%~n1.obj" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert)
llvm-lib "%objpath%\UefiLib\*.obj" /MACHINE:X64 /OUT:"%binpath%\UefiLib.Lib"
 
echo Compiling UefiDebugLibConOut...
for %%1 in (%mdepath%\Library\UefiDebugLibConOut\*.c) do (clang-cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\UefiDebugLibConOut\%%~n1.cod" /Fo"%objpath%\UefiDebugLibConOut\%%~n1.obj" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert)
llvm-lib "%objpath%\UefiDebugLibConOut\*.obj" /MACHINE:X64 /OUT:"%binpath%\UefiDebugLibConOut.Lib"

echo Compiling UefiMemoryAllocationLib...
clang-cl %mdepath%\Library\UefiMemoryAllocationLib\MemoryAllocationLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /Zi /W3 /WX /O2 /Oi /Fa"%objpath%\UefiMemoryAllocationLib\MemoryAllocationLib.cod" /Fo"%objpath%\UefiMemoryAllocationLib\MemoryAllocationLib.obj" /FI".\pcdhack.h" /GS- /Gy /GF /Gr /TC /c -Wno-microsoft-static-assert
llvm-lib "%objpath%\UefiMemoryAllocationLib\MemoryAllocationLib.obj" /MACHINE:X64 /OUT:"%binpath%\UefiMemoryAllocationLib.lib"

echo Completed!
pause.