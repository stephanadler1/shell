@if not defined _DEBUG echo off
setlocal

set "_TARGETDIR=%~dp0ToolsCache\Java"

if "%~1" equ "" goto :EOF
if not exist "%~1" goto :EOF
if not exist "%~1\bin\java.exe" goto :EOF

call ROBOCOPY "%~1" "%_TARGETDIR%" "*.*" /MIR

call :WriteVersionFile "%~1\.."

call "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -scan -disableremediation -scantype 3 -timeout 1 -file "%_TARGETDIR%"

echo:
pause
goto :EOF

:WriteVersionFile
echo Folder: "%~nx1"
if exist "%~1\..\%~nx1.zip" echo %~nx0 > "%_TARGETDIR%\%~nx1.zip.txt"
if not exist "%~1\..\%~nx1.zip" echo %~nx0 > "%_TARGETDIR%\%~nx1.txt"
goto :EOF

