@if not defined _DEBUG echo off
setlocal

set "_TARGETDIR=%~dp0ToolsCache\WinRAR"

if not exist "%ProgramFiles%\WinRAR\rar.exe" exit /b 0
if not exist "%_TARGETDIR%\rar.exe" exit /b 0

call robocopy "%ProgramFiles%\WinRAR" "%_TARGETDIR%" "*.*" /mir

call "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -scan -disableremediation -scantype 3 -timeout 1 -file "%~dp0."

pause
