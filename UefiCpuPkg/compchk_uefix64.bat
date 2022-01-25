@echo off
set edkpath=C:\UefiDKII
set mdepath=C:\UefiDKII\MdePkg
set mmppath=C:\UefiDKII\MdeModulePkg
set cpupath=C:\UefiDKII\UefiCpuPkg
set binpath=C:\UefiDKII\Bin\UefiCpuPkg\compchk_uefix64
set objpath=C:\UefiDKII\Bin\UefiCpuPkg\compchk_uefix64\Intermediate

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