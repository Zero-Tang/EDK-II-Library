@echo off

title Compiling PE2TE, Make Directory, 64-Bit Windows (AMD64 Architecture)
echo Project: PE2TE Converter
echo Platform: Universal
echo Preset: Make Directory
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2022, zero.tangptr@gmail.com. All Rights Reserved.
if "%~1"=="/s" (echo DO-NOT-PAUSE is activated!) else (pause)

echo Maing Directories...
mkdir .\compchk_win11x64\Intermediate
mkdir .\compfre_win11x64\Intermediate

echo Completed!
pause.