@if not defined _DEBUG echo off
setlocal

set "_TARGETDIR=%~dp0ToolsCache\Node"

if "%~1" equ "" goto UpdateNpmPackages
if not exist "%~1" goto UpdateNpmPackages
if not exist "%~1\node.exe" goto UpdateNpmPackages

call ROBOCOPY "%~1" "%_TARGETDIR%" "*.*" /MIR

if exist "%~1\..\..\%~nx1.zip" echo %~nx0 > "%_TARGETDIR%\%~nx1.zip.txt"
if not exist "%~1\..\..\%~nx1.zip" echo %~nx0 > "%_TARGETDIR%\%~nx1.txt"

call "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -scan -disableremediation -scantype 3 -timeout 1 -file "%_TARGETDIR%"

echo:

:UpdateNpmPackages
echo Ensure NPM has the latest version
call npm install -g npm@latest

call "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -scan -disableremediation -scantype 3 -timeout 1 -file "%_TARGETDIR%"


echo:
call npm version

echo:
pause
