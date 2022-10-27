@echo off
set edkpath=.\edk2

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
mkdir %objpath%\BaseIoLibIntrinsic
mkdir %objpath%\BaseMemoryLib
mkdir %objpath%\BasePrintLib
mkdir %objpath%\RegisterFilterLibNull
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
mkdir %objpath%\BaseIoLibIntrinsic
mkdir %objpath%\BaseMemoryLib
mkdir %objpath%\BasePrintLib
mkdir %objpath%\RegisterFilterLibNull
mkdir %objpath%\UefiBootServicesTableLib
mkdir %objpath%\UefiRuntimeServicesTableLib
mkdir %objpath%\UefiDevicePathLibDevicePathProtocol
mkdir %objpath%\UefiLib
mkdir %objpath%\UefiDebugLibConOut
mkdir %objpath%\UefiMemoryAllocationLib

echo Making Directories for MdeModulePkg...
mkdir %edkpath%\Bin\MdeModulePkg
set mmppath=%edkpath%\Bin\MdeModulePkg

echo Making Directories for Checked Build...
mkdir %mmppath%\compchk_uefix64
mkdir %mmppath%\compchk_uefix64\Intermediate
set objpath=%mmppath%\compchk_uefix64\Intermediate

mkdir %objpath%\RuntimeDxeCore
mkdir %objpath%\UefiSortLib
mkdir %objpath%\DxeResetSystemLib

echo Making Directories for Free Build...
mkdir %mmppath%\compfre_uefix64
mkdir %mmppath%\compfre_uefix64\Intermediate
set objpath=%mmppath%\compfre_uefix64\Intermediate

mkdir %objpath%\RuntimeDxeCore
mkdir %objpath%\UefiSortLib
mkdir %objpath%\DxeResetSystemLib

echo Making Directories for SourceLevelDebugPkg...
mkdir %edkpath%\Bin\SourceLevelDebugPkg
set sldpath=%edkpath%\Bin\SourceLevelDebugPkg

echo Making Directories for Checked Build...
mkdir %sldpath%\compchk_uefix64
mkdir %sldpath%\compchk_uefix64\Intermediate
set objpath=%sldpath%\compchk_uefix64\Intermediate

mkdir %objpath%\DebugAgent

echo Making Directories for UefiCpuPkg...
mkdir %edkpath%\Bin\UefiCpuPkg
set cpupath=%edkpath%\Bin\UefiCpuPkg

echo Making Directories for Checked Build...
mkdir %cpupath%\compchk_uefix64
mkdir %cpupath%\compchk_uefix64\Intermediate
set objpath=%cpupath%\compchk_uefix64\Intermediate

mkdir %objpath%\CpuDxe

echo Installing EDK2...
setx EDK2_PATH %cd%\edk2

echo Completed!
pause.