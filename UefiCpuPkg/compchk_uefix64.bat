@echo off
set edkpath=..\edk2
set mdepath=..\edk2\MdePkg
set mmppath=..\edk2\MdeModulePkg
set cpupath=..\edk2\UefiCpuPkg
set binpath=..\edk2\Bin\UefiCpuPkg\compchk_uefix64
set objpath=..\edk2\Bin\UefiCpuPkg\compchk_uefix64\Intermediate

title Compiling EDK-II-Library UefiCpuPkg, Checked Build, UEFI (AMD64 Architecture)
echo Project: EDK-II-Library UefiCpuPkg, Checked Build
echo Platform: Unified Extensible Firmware Interface
echo Preset: Debug/Checked Build
echo Powered by zero.tangptr@gmail.com
echo Copyright (c) 2020-2022, zero.tangptr@gmail.com. All Rights Reserved.
clang-cl --version
lld-link --version
pause

pause.