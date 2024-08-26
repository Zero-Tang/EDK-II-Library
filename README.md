# EDK II Library
Non-standard compiling script for EDK II Libraries.

## Introduction
This repository is intended for building EDK II Libraries in a non-standard method. It is designed as an auxiliary project for NoirVisor EFI branch since certain stuff included in EDK II is of course quite useful. However, including the entire EDK II into NoirVisor is somewhat inappropriate. Hence, this project will include the release version of source code of EDK II. \
Duly note that this is a non-standard method to build EDK II Libraries! Such non-standard method is designed for project [NoirVisor](https://github.com/Zero-Tang/NoirVisor).

## Motivation
Since there are so many source codes in EDK II, it will cost an unacceptable amount of time to compile them, even if I select only those required for NoirVisor EFI executables.

## MSVC Support
There are two sets of scripts for compiling EDK II Library: MSVC and LLVM. \
Deprecation of using LLVM is planned on 2025.

## Build
Download the EWDK11-26100 from [Microsoft](https://docs.microsoft.com/en-us/legal/windows/hardware/enterprise-wdk-license-2022). Mount it to V: drive. \
Download and install LLVM for Win64: https://github.com/llvm/llvm-project/releases \
Download and install Netwide Assembler (a.k.a NASM) for Win64: https://www.nasm.us/pub/nasm/releasebuilds/?C=M;O=D \
If this is your first time to build this repository, run `build_prep.bat` script prior to building it. \
Run `cleanup.bat` like that you did in Visual Studio cleanup. \
Make sure that LLVM and NASM directories are added to the `PATH` environment variable.

Due to the complexity of dependencies in EDK2, you will have to workaround submodules with long file names.
```
git config --global core.longpaths true
```
When you pull updates from this repository, make sure you update recursively.
```
git submodule update --init --recursive
```

### Build using Python script
You may use execute the python script to build EDK2. (Recommended since it can build almost all libraries in MdePkg with multiprocessing.)

The python script depends on EDK2's package manager. Due to Python's specific module importing syntax, you must copy the `edk2\BaseTools\Scripts\PackageDocumentTools\plugins` directory into the repository root. The `make_script.py` file cannot properly import that file due to this specific issue. \
You should prepare the building environment:
```
python make_script.py prep MdePkg MdePkg
```
You may build MdePkg with Checked preset:
```
python make_script.py build MdePkg MdePkg Checked
```
Future implementation may deprecate the batch script to build EDK2.

To cleanup:
```
python make_script.py clean MdePkg MdePkg
```

To build `MipiSysTLib`, you will have to execute `GenMipiSystH.py` script beforehand.

## Build BaseTools
The Python script does not work with BaseTools compilation. Please run the batch script for building BaseTools. \
Please note that the source codes for BaseTools are somehow broken that a few codes can't be built into 64-bit programs. This repository currently compile BaseTools into 32-bit Windows program only.

## Packages Included in Compilation
Currently, certain parts of `MdePkg` are included in compilation. Parts included in compilation depends on the need of project NoirVisor: https://github.com/Zero-Tang/NoirVisor

If you use the python script to build EDK II, most modules in `MdePkg` are compiled.

## Issue
Seldom might there be some typos in EDK II, resulted in compilation errors. These errors will remove the erroneous modules from library. Unless these modules are required for you to use, it is fine since it will not prevent the library from being generated. In case you require them, report the issue to [TianoCore Bugzilla](https://bugzilla.tianocore.org/).

`BaseFdtLib` will not be built because it has such specific preparations that our script can't generalize.

## Similar Project
[Alex Ionescu](https://github.com/ionescu007) made a project called [VisualUefi](https://github.com/ionescu007/VisualUefi).

# License
This repository is licensed under the MIT license. \
EDK II is licensed under the BSD-2-Clause+Patent License. View it on [EDK II GitHub Repository](https://github.com/tianocore/edk2/blob/master/License.txt)