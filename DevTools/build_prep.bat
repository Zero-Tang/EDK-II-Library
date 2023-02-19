@echo off

title Compiling DevTools, Make Directory, 64-Bit Windows (AMD64 Architecture)
echo Project: EDK-II Library DevTools
echo Platform: Universal
echo Preset: Make Directory
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2022, zero.tangptr@gmail.com. All Rights Reserved.
if "%~1"=="/s" (echo DO-NOT-PAUSE is activated!) else (pause)

echo Maing Directories...
mkdir .\bin\compchk_win11x64\Intermediate\Common
mkdir .\bin\compfre_win11x64\Intermediate\Common
mkdir .\bin\compchk_win11x64\Intermediate\PE2TE
mkdir .\bin\compfre_win11x64\Intermediate\PE2TE
mkdir .\bin\compchk_win11x64\Intermediate\DumpAnalyzer
mkdir .\bin\compfre_win11x64\Intermediate\DumpAnalyzer

echo Completed!
pause.