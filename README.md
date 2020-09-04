# EDK II Library
Non-standard compiling script for EDK II Libraries using LLVM

## Introduction
This repository is intended for building EDK II Libraries in a non-standard method. It is designed as an auxiliary project for NoirVisor EFI branch since certain stuff included in EDK II is of course quite useful. However, including the entire EDK II into NoirVisor is somewhat inappropriate. Hence, this project will include the release version of source code of EDK II. <br>
Duly note that this is a non-standard method to build EDK II Libraries! Such non-standard method is designed for project [NoirVisor](https://github.com/Zero-Tang/NoirVisor).

## Build
Download and install LLVM for Win64: https://github.com/llvm/llvm-project/releases <br>
Download and install Netwide Assembler (a.k.a NASM) for Win64: https://www.nasm.us/pub/nasm/releasebuilds/?C=M;O=D <br>
Download source code of EDK II: https://github.com/tianocore/edk2/releases and extract to `C:\UefiDKII` path. <br>
If this is your first time to build this repository, run `build_prep.bat` script prior to building it. <br>
Run `cleanup.bat` like that you did in Visual Studio cleanup.

## Packages Included in Compilation
Currently, certain parts of `MdePkg` are included in compilation. Parts included in compilation depends on the need of project NoirVisor: https://github.com/Zero-Tang/NoirVisor

## Issue
Seldom, there might be some typos in EDK II, resulted in compilation errors. These errors will remove the erroneous modules from library. Unless these modules are required for you to use, it is fine since it will not prevent the library from being generated. In case you require them, report the issue to [TianoCore Bugzilla](https://bugzilla.tianocore.org/). <br>

## Similar Project
[Alex Ionescu](https://github.com/ionescu007) made a project called [VisualUefi](https://github.com/ionescu007/VisualUefi). <br>
However, compilation is done by Visual Studio. In project NoirVisor, EFI executables are compiled by LLVM-Clang. Static libraries compiled by VisualUefi are not linkable via LLVM-LLD, so I made this project: compile EDK II libraries via LLVM-Clang and via Netwide Assembler and link them into static libraries so that they are linkable via LLVM-LLD.

# License
This repository is licensed under the MIT license. <br>
EDK II is licensed under the BSD-2-Clause+Patent License. View it on [EDK II GitHub Repository](https://github.com/tianocore/edk2/blob/master/License.txt)