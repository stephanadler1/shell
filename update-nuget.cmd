@if not defined _DEBUG echo off
setlocal

set "_TARGETDIR=%~dp0ToolsCache\Nuget"

call "%_TARGETDIR%\nuget.exe" update -self

call "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -scan -disableremediation -scantype 3 -timeout 1 -file "%_TARGETDIR%"

pause
