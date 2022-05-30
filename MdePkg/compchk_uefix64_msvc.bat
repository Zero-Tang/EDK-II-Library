@echo off
set ddkpath=V:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.31.31103
set path=%ddkpath%\bin\Hostx64\x64;%path%
set edkpath=C:\UefiDKII
set mdepath=C:\UefiDKII\MdePkg
set binpath=C:\UefiDKII\Bin\MdePkg\compchk_uefix64
set objpath=C:\UefiDKII\Bin\MdePkg\compchk_uefix64\Intermediate

title Compiling EDK-II-Library MdePkg, Checked Build, UEFI (AMD64 Architecture)
echo Project: EDK-II-Library MdePkg, Checked Build
echo Platform: Unified Extensible Firmware Interface
echo Preset: Debug/Checked Build
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2020-2022, zero.tangptr@gmail.com. All Rights Reserved.
pause

echo Compiling BaseLib...
for %%1 in (%mdepath%\Library\BaseLib\*.c) do (cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I"%mdepath%\Test\UnitTest\Include" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\BaseLib\%%~n1.cod" /Fo"%objpath%\BaseLib\%%~n1.obj" /Fd"%objpath%\vc140.pdb" /FI"%mdepath%\Library\BaseLib\BaseLibInternals.h" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c)
del %objpath%\BaseLib\X86UnitTestHost.*
for %%1 in (%mdepath%\Library\BaseLib\X64\*.nasm) do (nasm -o "%objpath%\BaseLib\%%~n1.obj" -fwin64 -g -I"%mdepath%\Library\BaseLib" -I"%mdepath%\Include" -I"%mdepath%\Include\X64" -P".\pcdhack.nasm" %%1)
del %objpath%\BaseLib\UnitTestHost.obj
del %objpath%\BaseLib\IntelTdxNull.obj
lib "%objpath%\BaseLib\*.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\BaseLib.Lib"

echo Compiling BaseDebugPrintErrorLevelLib...
cl %mdepath%\Library\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.cod" /Fo"%objpath%\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.obj" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c
lib "%objpath%\BaseDebugPrintErrorLevelLib\BaseDebugPrintErrorLevelLib.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\BaseDebugPrintErrorLevelLib.lib"

echo Compiling BaseIoLibIntrinsic...
cl %mdepath%\Library\BaseIoLibIntrinsic\IoLibMsc.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\BaseIoLibIntrinsic\IoLibMsc.cod" /Fo"%objpath%\BaseIoLibIntrinsic\IoLibMsc.obj" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c
cl %mdepath%\Library\BaseIoLibIntrinsic\IoLibMmioBuffer.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\BaseIoLibIntrinsic\IoLibMmioBuffer.cod" /Fo"%objpath%\BaseIoLibIntrinsic\IoLibMmioBuffer.obj" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c
cl %mdepath%\Library\BaseIoLibIntrinsic\IoLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\BaseIoLibIntrinsic\IoLib.cod" /Fo"%objpath%\BaseIoLibIntrinsic\IoLib.obj" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c
for %%1 in (%mdepath%\Library\BaseIoLibIntrinsic\*.nasm) do (nasm -o "%objpath%\BaseIoLibIntrinsic\%%~n1.obj" -fwin64 -g -I"%mdepath%\Include" -I"%mdepath%\Include\X64" %%1)
lib "%objpath%\BaseIoLibIntrinsic\*.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\BaseIoLibIntrinsic.Lib"

echo Compiling BaseMemoryLib...
for %%1 in (%mdepath%\Library\BaseMemoryLib\*.c) do (cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\BaseMemoryLib\%%~n1.cod" /Fo"%objpath%\BaseMemoryLib\%%~n1.obj" /Fd"%objpath%\vc140.pdb" /FI"%mdepath%\Library\BaseMemoryLib\MemLibInternals.h" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c)
lib "%objpath%\BaseMemoryLib\*.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\BaseMemoryLib.Lib"

echo Compiling BasePrintLib...
for %%1 in (%mdepath%\Library\BasePrintLib\*.c) do (cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\BasePrintLib\%%~n1.cod" /Fo"%objpath%\BasePrintLib\%%~n1.obj" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c)
lib "%objpath%\BasePrintLib\*.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\BasePrintLib.Lib"

echo Compiling RegisterFilterLibNull...
cl %mdepath%\Library\RegisterFilterLibNull\RegisterFilterLibNull.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\RegisterFilterLibNull\RegisterFilterLibNull.cod" /Fo"%objpath%\RegisterFilterLibNull\RegisterFilterLibNull.obj" /Fd"%objpath%\vc140.pdb" /FI"%mdepath%\Include\Uefi.h" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c
lib "%objpath%\RegisterFilterLibNull\RegisterFilterLibNull.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\RegisterFilterLibNull.Lib"

echo Compiling UefiBootServicesTableLib...
cl %mdepath%\Library\UefiBootServicesTableLib\UefiBootServicesTableLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\UefiBootServicesTableLib\UefiBootServicesTableLib.cod" /Fo"%objpath%\UefiBootServicesTableLib\UefiBootServicesTableLib.obj" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c
lib "%objpath%\UefiBootServicesTableLib\UefiBootServicesTableLib.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\UefiBootServicesTableLib.Lib"

echo Compiling UefiRuntimeServicesTableLib...
cl %mdepath%\Library\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.cod" /Fo"%objpath%\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.obj" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c
lib "%objpath%\UefiRuntimeServicesTableLib\UefiRuntimeServicesTableLib.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\UefiRuntimeServicesTableLib.Lib"

echo Compiling UefiDevicePathLibDevicePathProtocol...
cl %mdepath%\Library\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.cod" /Fo"%objpath%\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.obj" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c
lib "%objpath%\UefiDevicePathLibDevicePathProtocol\UefiDevicePathLib.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\UefiDevicePathLib.Lib"

echo Compiling UefiLib...
for %%1 in (%mdepath%\Library\UefiLib\*.c) do (cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\UefiLib\%%~n1.cod" /Fo"%objpath%\UefiLib\%%~n1.obj" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c)
lib "%objpath%\UefiLib\*.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\UefiLib.Lib"
 
echo Compiling UefiDebugLibConOut...
for %%1 in (%mdepath%\Library\UefiDebugLibConOut\*.c) do (cl %%1 /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\UefiDebugLibConOut\%%~n1.cod" /Fo"%objpath%\UefiDebugLibConOut\%%~n1.obj" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c)
lib "%objpath%\UefiDebugLibConOut\*.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\UefiDebugLibConOut.Lib"

echo Compiling UefiMemoryAllocationLib...
cl %mdepath%\Library\UefiMemoryAllocationLib\MemoryAllocationLib.c /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I".\\" /Zi /nologo /W3 /WX /Od /Oi /FAcs /Fa"%objpath%\UefiMemoryAllocationLib\MemoryAllocationLib.cod" /Fo"%objpath%\UefiMemoryAllocationLib\MemoryAllocationLib.obj" /Fd"%objpath%\vc140.pdb" /FI"pcdhack.h" /GS- /Gr /TC /c
lib "%objpath%\UefiMemoryAllocationLib\MemoryAllocationLib.obj" /MACHINE:X64 /NOLOGO /OUT:"%binpath%\UefiMemoryAllocationLib.lib"

echo Completed!
pause.