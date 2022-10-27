@echo off

title Compiling PE2TE, Clean-up, 64-Bit Windows (AMD64 Architecture)
echo Project: PE2TE Converter
echo Platform: Universal
echo Preset: Clean-up
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2022, zero.tangptr@gmail.com. All Rights Reserved.
if "%~1"=="/s" (echo DO-NOT-PAUSE is activated!) else (pause)

echo Cleaning Build Directory...
del .\compchk_win11x64 /q /s
del .\compfre_win11x64 /q /s

echo Completed!
pause.