@echo off
set edkpath=..\edk2
set srcpath=..\edk2\BaseTools\Source\C
set mdepath=..\edk2\MdePkg
set ddkpath=V:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.31.31103
set path=%ddkpath%\bin\Hostx86\x86;V:\Program Files\Windows Kits\10\bin\10.0.22621.0\x86;%path%
set incpath=V:\Program Files\Windows Kits\10\Include\10.0.22621.0
set libpath=V:\Program Files\Windows Kits\10\Lib\10.0.22621.0
set binpath=..\bin\BaseTools\compfre_win11x86
set objpath=..\bin\BaseTools\compfre_win11x86\Intermediate

echo +---------------------------------+
echo + Building Common Utilitiies...   +
echo +---------------------------------+
echo Compiling...
for %%1 in (%srcpath%\Common\*.c) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /I"%mdepath%\Include" /Zi /nologo /W3 /wd4267 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\Common\%%~n1.cod" /Fo"%objpath%\Common\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue)

echo Linking...
lib "%objpath%\Common\*.obj" /NOLOGO /Machine:X86 /OUT:"%binpath%\Common.lib"

echo +------------------------------+
echo + Building BrotliCompress...   +
echo +------------------------------+
echo Compiling...
cl %srcpath%\BrotliCompress\BrotliCompress.c /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\BrotliCompress\brotli\c\include" /Zi /nologo /W3 /wd4244 /wd4267 /wd4018 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\BrotliCompress\BrotliCompress.cod" /Fo"%objpath%\BrotliCompress\BrotliCompress.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue

echo Compiling Common Objects...
for %%1 in (%srcpath%\BrotliCompress\brotli\c\common\*.c) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\BrotliCompress\brotli\c\include" /Zi /nologo /W3 /wd4334 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\BrotliCompress\common\%%~n1.cod" /Fo"%objpath%\BrotliCompress\common\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue)

echo Compiling Decoder...
for %%1 in (%srcpath%\BrotliCompress\brotli\c\dec\*.c) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\BrotliCompress\brotli\c\include" /Zi /nologo /W3 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\BrotliCompress\dec\%%~n1.cod" /Fo"%objpath%\BrotliCompress\dec\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue)

echo Compiling Encoder...
for %%1 in (%srcpath%\BrotliCompress\brotli\c\enc\*.c) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\BrotliCompress\brotli\c\include" /Zi /nologo /W3 /wd4334 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\BrotliCompress\enc\%%~n1.cod" /Fo"%objpath%\BrotliCompress\enc\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue)

echo Linking...
link "%objpath%\BrotliCompress\BrotliCompress.obj" "%objpath%\BrotliCompress\common\*.obj" "%objpath%\BrotliCompress\dec\*.obj" "%objpath%\BrotliCompress\enc\*.obj" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\BrotliCompress.pdb" /OUT:"%binpath%\BrotliCompress.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +-------------------------------+
echo + Building DevicePath Tools...  +
echo +-------------------------------+
echo Compiling...
for %%1 in (%srcpath%\DevicePath\*.c) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /I"%mdepath%\Include" /Zi /nologo /W3 /wd4334 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\DevicePath\%%~n1.cod" /Fo"%objpath%\DevicePath\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue)

echo Linking...
link "%objpath%\DevicePath\*.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\DevicePath.pdb" /OUT:"%binpath%\DevicePath.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +--------------------------+
echo + Building EfiRom Tools... +
echo +--------------------------+
echo Compiling...
cl %srcpath%\EfiRom\EfiRom.c /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /I"%mdepath%\Include" /Zi /nologo /W3 /wd4244 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\EfiRom\EfiRom.cod" /Fo"%objpath%\EfiRom\EfiRom.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue

echo Linking...
link "%objpath%\EfiRom\EfiRom.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\EfiRom.pdb" /OUT:"%binpath%\EfiRom.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +----------------------------+
echo + Building GenCrc32 Tools... +
echo +----------------------------+
echo Compiling...
cl %srcpath%\GenCrc32\GenCrc32.c /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /Zi /nologo /W3 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\GenCrc32\GenCrc32.cod" /Fo"%objpath%\GenCrc32\GenCrc32.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue

echo Linking...
link "%objpath%\GenCrc32\GenCrc32.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\GenCrc32.pdb" /OUT:"%binpath%\GenCrc32.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +--------------------------+
echo + Building GenFfs Tools... +
echo +--------------------------+
echo Compiling...
cl %srcpath%\GenFfs\GenFfs.c /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /I"%mdepath%\Include" /Zi /nologo /W3 /wd4244 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\GenFfs\GenFfs.cod" /Fo"%objpath%\GenFfs\GenFfs.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue

echo Linking...
link "%objpath%\GenFfs\GenFfs.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\GenFfs.pdb" /OUT:"%binpath%\GenFfs.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +--------------------------+
echo + Building GenFv Tools...  +
echo +--------------------------+
echo Compiling...
for %%1 in (%srcpath%\GenFv\*.c) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /I"%mdepath%\Include" /Zi /nologo /W3 /wd4334 /wd4244 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\GenFv\%%~n1.cod" /Fo"%objpath%\GenFv\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue)

echo Linking...
link "%objpath%\GenFv\*.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\GenFv.pdb" /OUT:"%binpath%\GenFv.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +--------------------------+
echo + Building GenFw Tools...  +
echo +--------------------------+
echo Compiling...
for %%1 in (%srcpath%\GenFw\*.c) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /I"%mdepath%\Include" /Zi /nologo /W3 /wd4334 /wd4244 /wd4267 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\GenFw\%%~n1.cod" /Fo"%objpath%\GenFw\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue)

echo Linking...
link "%objpath%\GenFw\*.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\GenFw.pdb" /OUT:"%binpath%\GenFw.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +--------------------------+
echo + Building GenSec Tools... +
echo +--------------------------+
echo Compiling...
cl %srcpath%\GenSec\GenSec.c /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /I"%mdepath%\Include" /Zi /nologo /W3 /wd4244 /wd4267 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\GenSec\GenSec.cod" /Fo"%objpath%\GenSec\GenSec.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue

echo Linking...
link "%objpath%\GenSec\GenSec.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\GenSec.pdb" /OUT:"%binpath%\GenSec.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +---------------------------+
echo + Building LzmaCompress...  +
echo +---------------------------+
echo Compiling...
cl %srcpath%\LzmaCompress\LzmaCompress.c /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /Zi /nologo /W3 /WX /O2 /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\LzmaCompress\LzmaCompress.cod" /Fo"%objpath%\LzmaCompress\LzmaCompress.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue

for %%1 in (%srcpath%\LzmaCompress\Sdk\C\*.c) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /Zi /nologo /W3 /wd4334 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\LzmaCompress\%%~n1.cod" /Fo"%objpath%\LzmaCompress\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue)

echo Linking...
link "%objpath%\LzmaCompress\*.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\LzmaCompress.pdb" /OUT:"%binpath%\LzmaCompress.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +------------------------------+
echo + Building TianoCompressor...  +
echo +------------------------------+
echo Compiling...
cl %srcpath%\TianoCompress\TianoCompress.c /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /Zi /nologo /W3 /wd4244 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\TianoCompress\TianoCompress.cod" /Fo"%objpath%\TianoCompress\TianoCompress.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue

echo Linking...
link "%objpath%\TianoCompress\TianoCompress.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\TianoCompress.pdb" /OUT:"%binpath%\TianoCompress.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +----------------------------------+
echo + Building VfrCompile - Support... +
echo +----------------------------------+
echo Compiling...
cl %srcpath%\VfrCompile\Pccts\support\set\set.c /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\VfrCompile\Pccts\h" /Zi /nologo /W3 /wd4334 /wd4244 /wd4018 /wd4101 /wd4477 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /D"__USE_PROTOS" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\VfrCompile\Pccts\support\set\set.cod" /Fo"%objpath%\VfrCompile\Pccts\support\set\set.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue

echo +----------------------------------+
echo + Building VfrCompile - antlr ...  +
echo +----------------------------------+
echo Compiling...
for %%1 in (%srcpath%\VfrCompile\Pccts\antlr\*.c) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\VfrCompile\Pccts\h" /I"%srcpath%\VfrCompile\Pccts\support\set" /Zi /nologo /W3 /wd4334 /wd4244 /wd4018 /wd4101 /wd4477 /wd4068 /wd4700 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /D"__USE_PROTOS" /D"USER_ZZSYN" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\VfrCompile\Pccts\antlr\%%~n1.cod" /Fo"%objpath%\VfrCompile\Pccts\antlr\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue)

echo Linking...
link "%objpath%\VfrCompile\Pccts\antlr\*.obj" "%objpath%\VfrCompile\Pccts\support\set\set.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\antlr.pdb" /OUT:"%binpath%\antlr.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +--------------------------------+
echo + Building VfrCompile - dlg ...  +
echo +--------------------------------+
echo Compiling...
for %%1 in (%srcpath%\VfrCompile\Pccts\dlg\*.c) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\VfrCompile\Pccts\h" /I"%srcpath%\VfrCompile\Pccts\support\set" /Zi /nologo /W3 /wd4334 /wd4244 /wd4018 /wd4101 /wd4477 /wd4068 /wd4700 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /D"__USE_PROTOS" /D"USER_ZZSYN" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\VfrCompile\Pccts\dlg\%%~n1.cod" /Fo"%objpath%\VfrCompile\Pccts\dlg\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue)

echo Linking...
link "%objpath%\VfrCompile\Pccts\dlg\*.obj" "%objpath%\VfrCompile\Pccts\support\set\set.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\dlg.pdb" /OUT:"%binpath%\dlg.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +--------------------------+
echo + Building VfrCompile...   +
echo +--------------------------+
echo Generating...
set toolspath=%cd%\..\bin\BaseTools\compchk_win11x86
pushd .
cd %srcpath%\VfrCompile
%toolspath%\antlr.exe -CC -e3 -ck 3 -k 2 -fl VfrParser.dlg -ft VfrTokens.h -o . VfrSyntax.g
popd
%toolspath%\dlg.exe -C2 -i -CC -cl VfrLexer -o %srcpath%\VfrCompile %srcpath%\VfrCompile\VfrParser.dlg

echo Compiling...
for %%1 in (%srcpath%\VfrCompile\*.cpp) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /I"%srcpath%\VfrCompile\Pccts\h" /Zi /nologo /W3 /wd4334 /wd4244 /wd4018 /wd4101 /wd4102 /wd4530 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /D"PCCTS_USE_NAMESPACE_STD" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\VfrCompile\%%~n1.cod" /Fo"%objpath%\VfrCompile\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TP /c /errorReport:queue)

for %%1 in (%srcpath%\VfrCompile\Pccts\h\*.cpp) do (cl %%1 /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /Zi /nologo /W3 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\VfrCompile\Pccts\h\%%~n1.cod" /Fo"%objpath%\VfrCompile\Pccts\h\%%~n1.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TP /c /errorReport:queue)

echo Linking...
link "%objpath%\VfrCompile\*.obj" "%objpath%\VfrCompile\Pccts\h\*.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\VfrCompile.pdb" /OUT:"%binpath%\VfrCompile.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo +----------------------+
echo + Building VolInfo...  +
echo +----------------------+
echo Compiling...
cl %srcpath%\VolInfo\VolInfo.c /I"%ddkpath%\include" /I"%incpath%\um" /I"%incpath%\shared" /I"%incpath%\ucrt" /I"%srcpath%\Common" /I"%srcpath%\Include" /I"%mdepath%\Include\Ia32" /I"%mdepath%\Include" /Zi /nologo /W3 /wd4244 /wd4267 /WX /O2 /D"_CRT_SECURE_NO_WARNINGS" /D"_CRT_NONSTDC_NO_DEPRECATE" /Zc:wchar_t /std:c17 /FAcs /Fa"%objpath%\VolInfo\VolInfo.cod" /Fo"%objpath%\VolInfo\VolInfo.obj" /Fd"%objpath%\vc143.pdb" /GS- /Qspectre /TC /c /errorReport:queue

echo Linking...
link "%objpath%\VolInfo\VolInfo.obj" "%binpath%\Common.lib" /LIBPATH:"%libpath%\um\x86" /LIBPATH:"%libpath%\ucrt\x86" /LIBPATH:"%ddkpath%\lib\x86" /NOLOGO /OPT:REF /DEBUG /INCREMENTAL:NO /PDB:"%binpath%\VolInfo.pdb" /OUT:"%binpath%\VolInfo.exe" /SUBSYSTEM:CONSOLE /Machine:X86 /ERRORREPORT:QUEUE

echo BaseTools Build Complete!
pause.