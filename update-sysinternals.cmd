@if not defined _DEBUG echo off
setlocal

set _SYSINTERNALSLIVE=\\live.sysinternals.com\tools

set _TARGETDIR=%TOOLS%\Sysinternals
if not defined TOOLS set _TARGETDIR=%~dp0ToolsCache\Sysinternals

echo Connecting to %_SYSINTERNALSLIVE%...
pushd "%_SYSINTERNALSLIVE%"
if errorlevel 1 goto ErrorConnect

if exist "%_TARGETDIR%" (
    rem Kill the apps that are usually running
    "%_TARGETDIR%\pskill.exe" -accepteula procexp > nul 2>&1
    "%_TARGETDIR%\pskill.exe" -accepteula procexp64 > nul 2>&1
) else (
    md "%_TARGETDIR%" > nul 2>&1
)

echo You are in '%CD%'.
robocopy . "%_TARGETDIR%" /MIR /DST /R:5
echo Last updated: %DATE% %TIME% > "%_TARGETDIR%\_LastUpdated.txt"

rem Restart the apps that should be running
start /d "%_TARGETDIR%" /min procexp -accepteula

pause
goto EOF


:ErrorConnect
    echo *** Failed to connect to %_SYSINTERNALSLIVE%.
    pause
    exit /b 1