@if not defined _DEBUG echo off
setlocal

set "_TARGETDIR=%~dp0ToolsCache\Python"

if "%~1" equ "" if "%~1" equ "" call explorer "%APPDATA%\..\Local\Programs\Python"

if not exist "%~1" goto :EOF
if not exist "%~1\python.exe" goto :EOF

call ROBOCOPY "%~1" "%_TARGETDIR%" "*.*" /MIR

call "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -scan -disableremediation -scantype 3 -timeout 1 -file "%_TARGETDIR%"

echo:
pause
goto :EOF
