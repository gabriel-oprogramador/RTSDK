@echo off
setlocal EnableExtensions

for %%I in ("%~dp0..") do set "ROOT=%%~fI"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

for %%I in ("%ROOT%") do set "RTSDK_ROOT=%%~fI"
set "RTSDK_ROOT=%RTSDK_ROOT:\=/%"
set "LLVM_VERSION=20260602"
set "LLVM_BIN=%RTSDK_ROOT%/Toolchain/llvm-mingw/%LLVM_VERSION%/bin"
set "BUSY_BIN=%RTSDK_ROOT%/Toolchain/llvm-mingw/%LLVM_VERSION%/busybox/bin"
set "PATH=%BUSY_BIN%;%LLVM_BIN%;%PATH%"

robocopy "%RTSDK_ROOT%/Template/.vscode" "./.vscode" /E /XC /XN /XO /NFL /NDL /NJH /NJS

"%BUSY_BIN%\make.exe" -f"%ROOT%\Build\Game.mk" RTSDK_ROOT=%RTSDK_ROOT% %*

exit /b %ERRORLEVEL%