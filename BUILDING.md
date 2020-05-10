# Build instructions

# x64

## libwebp
Compiling libwebp.dll requires Visual Studio IDE.

Download the latest source for libwebp here: https://storage.googleapis.com/downloads.webmproject.org/releases/webp/index.html

Extract the source to the `.\lib\` folder (or any other folder)

Open `x64 Native Tools Command Prompt for VS`, navigate to the root directory of the libwebp source and run the command below to build:

```
nmake /f Makefile.vc CFG=release-dynamic RTLIBCFG=dynamic OBJDIR=output
````

The libwebp.dll binary should be available in `.\output\release-dynamic\x64\bin\libwebp.dll`

Move the compiled binary to the `.\bin\x64` directory of this project. 

## The executable

Set build target to Win64 for project in Delphi and build.

Output is in `.\bin\x64`

# x86

Follow the same instructions but use `Developer Command Promt for VS` and move to `.\bin\x86`