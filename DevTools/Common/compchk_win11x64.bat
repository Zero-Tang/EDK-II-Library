@echo off
set edkpath=%EDK2_PATH%\edk2
set ddkpath=V:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.31.31103
set path=%ddkpath%\bin\Hostx64\x64;V:\Program Files\Windows Kits\10\bin\10.0.22621.0\x64;%path%
set incpath=V:\Program Files\Windows Kits\10\Include\10.0.22621.0
set libpath=V:\Program Files\Windows Kits\10\Lib\10.0.22621.0
set binpath=..\bin\compchk_win11x64
set objpath=..\bin\compchk_win11x64\Intermediate\Common

title Compiling Common Library, Checked Build, 64-Bit Windows (AMD64 Architecture)
echo Project: Common Library for Development Tools
echo Platform: 64-Bit Windows
echo Preset: Debug/Checked Build
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2022, zero.tangptr@gmail.com. All Rights Reserved.
if "%~1"=="/s" (echo DO-NOT-PAUSE is activated!) else (pause)

echo ============Start Compiling============
for %%1 in (.\*.c) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"..\Include" /Zi /nologo /W3 /wd4267 /WX /Od /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\%%~n1.cod" /Fo"%objpath%\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue)

echo ============Start Linking============
lib "%objpath%\*.obj" /NOLOGO /Machine:X64 /OUT:"%binpath%\Common.lib"

if "%~1"=="/s" (echo Completed!) else (pause)