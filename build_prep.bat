@echo off
set edkpath=C:\UefiDKII

title EDK II Library Compilation Preparation
echo Project: EDK II Library
echo Platform: Universal (Non-Binary Build)
echo Preset: Directory Build
echo Powered by zero.tangptr@gmail.com
echo Warning: You are supposed to execute this batch file to build directories for first-time compilation.
echo Besides first-time compilation, you are not expected to execute this batch file at anytime.
pause.

echo Starting Compilation Preparations...
mkdir %edkpath%\Bin

echo Making Directories for MdePkg...
mkdir %edkpath%\Bin\MdePkg
set mdepath=%edkpath%\Bin\MdePkg

echo Making Directories for Checked Build...
mkdir %mdepath%\compchk_uefix64
mkdir %mdepath%\compchk_uefix64\Intermediate
set objpath=%mdepath%\compchk_uefix64\Intermediate

mkdir %objpath%\BaseLib
mkdir %objpath%\BaseDebugPrintErrorLevelLib
mkdir %objpath%\BaseMemoryLib
mkdir %objpath%\BasePrintLib
mkdir %objpath%\UefiBootServicesTableLib
mkdir %objpath%\UefiRuntimeServicesTableLib
mkdir %objpath%\UefiDevicePathLibDevicePathProtocol
mkdir %objpath%\UefiLib
mkdir %objpath%\UefiDebugLibConOut
mkdir %objpath%\UefiMemoryAllocationLib

echo Making Directories for Free Build
mkdir %mdepath%\compfre_uefix64
mkdir %mdepath%\compfre_uefix64\Intermediate
set objpath=%mdepath%\compfre_uefix64\Intermediate

mkdir %objpath%\BaseLib
mkdir %objpath%\BaseDebugPrintErrorLevelLib
mkdir %objpath%\BaseMemoryLib
mkdir %objpath%\BasePrintLib
mkdir %objpath%\UefiBootServicesTableLib
mkdir %objpath%\UefiRuntimeServicesTableLib
mkdir %objpath%\UefiDevicePathLibDevicePathProtocol
mkdir %objpath%\UefiLib
mkdir %objpath%\UefiDebugLibConOut
mkdir %objpath%\UefiMemoryAllocationLib

echo Completed!
pause.