@echo off
setlocal
set "BUSY=.\Toolchain\llvm-mingw\20260602\busybox\bin"
set "PATH=%BUSY%;%PATH%"
"%BUSY%\make.exe" %*
endlocal