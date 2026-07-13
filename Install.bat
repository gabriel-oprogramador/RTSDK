@echo off
setlocal

call :main
exit /b %ERRORLEVEL%

:main
set "TEMP_SDK=.\SDK"
set "INSTALL_DIR=%LOCALAPPDATA%\RaylibTemplate"

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
echo Install Dir "%INSTALL_DIR%"

call "Scripts\Setup.bat"
call ".\ProjectBuild.bat" ship TARGET=Web
call ".\ProjectBuild.bat" ship TARGET=Windows
call ".\ProjectBuild.bat" make_sdk

echo Installing SDK...
robocopy "%TEMP_SDK%" "%INSTALL_DIR%" /E /NFL /NDL /NJH /NJS
if %ERRORLEVEL% GEQ 8 exit /b %ERRORLEVEL%
rmdir /S /Q ".\SDK"
echo SDK installed!

exit /b 0