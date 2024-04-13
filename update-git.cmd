@if not defined _DEBUG echo off
setlocal

set "_TARGETDIR=%~dp0.\ToolsCache\git.portable"
call robocopy "%~1" "%_TARGETDIR%" *.* /MIR
call "%_TARGETDIR%\bin\git.exe" config --system --unset credential.helper helper-selector
call "%_TARGETDIR%\bin\git.exe" config --system -l

call "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -scan -disableremediation -scantype 3 -timeout 1 -file "%_TARGETDIR%"

pause
