@echo off
set ddkpath=V:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.38.33130
set path=%ddkpath%\bin\Hostx64\x64;%path%
set edkpath=..\edk2
set mdepath=..\edk2\MdePkg
set libcpath=..\edk2-libc
set binpath=..\bin\edk2-libc\StdLib\compchk_uefix64
set objpath=..\bin\edk2-libc\StdLib\compchk_uefix64\Intermediate

title Compiling EDK-II-Library MdePkg, Checked Build, UEFI (AMD64 Architecture)
echo Project: EDK-II-Library MdePkg, Checked Build
echo Platform: Unified Extensible Firmware Interface
echo Preset: Debug/Checked Build
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2020-2022, zero.tangptr@gmail.com. All Rights Reserved.
pause

echo Compiling LibC...
set stdio_path=%libcpath%\StdLib\LibC\Stdio
for %%1 in (%stdio_path%\*.c) do (cl %%1 /I".." /I"%mdepath%\Include" /I"%mdepath%\Include\X64" /I"%libcpath%\StdLibPrivateInternalFiles\Include" /I"%libcpath%\StdLibPrivateInternalFiles\Include\X64" /I"%libcpath%\StdLib\Include" /I"%libcpath%\StdLib\Include\X64" /Zi /nologo /W3 /WX- /Od /FAcs /Fa"%objpath%\LibC\Stdio\%%~n1.cod" /Fo"%objpath%\LibC\Stdio\%%~n1.obj" /Fd"%objpath%\vc140.pdb" /FI"MdePkg_pcdhack.h" /GS- /Gr /TC /Qspectre /c)

lib "%objpath%\LibC\Stdio\*.obj" /Machine:X64 /NOLOGO /OUT:"%binpath%\LibC.lib"

pause