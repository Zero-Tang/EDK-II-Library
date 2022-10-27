@echo off
set edkpath=..\edk2

title EDK-II-Library Cleanup
echo Project: EDK-II-Library
echo Platform: Universal (Non-Binary Build)
echo Preset: Cleanup
echo Powered by zero.tangptr@gmail.com
echo Warning: All compiled binaries, including intermediate files, will be deleted!
pause.

echo Performing cleanup...
del %edkpath%\Bin /q /s

echo Cleanup Completed!
pause.