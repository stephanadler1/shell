@if not defined _DEBUG echo off
setlocal

set "_SYSINTERNALSLIVE=\\live.sysinternals.com\tools"
set "_TARGETDIR=%TOOLS%\Sysinternals"
if not defined TOOLS set "_TARGETDIR=%~dp0ToolsCache\Sysinternals"

echo Connecting to %_SYSINTERNALSLIVE%...
pushd "%_SYSINTERNALSLIVE%"
if errorlevel 1 goto ErrorConnect


if not exist "%_TARGETDIR%" goto KillRunningApps

rem Is there anything new that needs copying? Even though Robocopy is
rem used below, it doesn't quite work with the "Live Share" drive system,
rem all files are always considered changed.
for /f "tokens=1* delims=:" %%a in ('call findstr "^PsTools Version in this package" "%_SYSINTERNALSLIVE%\psversion.txt"') do (set "_SOURCEVER=%%b")
for /f "tokens=1* delims=:" %%a in ('call findstr "^PsTools Version in this package" "%_TARGETDIR%\psversion.txt"') do (set "_TARGETVER=%%b")
if "%_SOURCEVER%" equ "%_TARGETVER%" (
    (
        echo No changes detected. Exiting...
        echo Source version: %_SOURCEVER%
        echo:
        echo Press Ctrl+C to exit or Enter to copy anyway.
    ) 1>&2

    pause
    if errorlevel 1 goto :ExitWithError
)

:KillRunningApps
if exist "%_TARGETDIR%" (
    rem Kill the apps that are usually running
    call "%_TARGETDIR%\pskill.exe" -accepteula procexp > nul 2>&1
    call "%_TARGETDIR%\pskill.exe" -accepteula procexp64 > nul 2>&1
    call "%_TARGETDIR%\pskill.exe" -accepteula zoomit > nul 2>&1
    call "%_TARGETDIR%\pskill.exe" -accepteula zoomit64 > nul 2>&1
) else (
    md "%_TARGETDIR%" > nul 2>&1
)

echo You are in '%CD%'.
call robocopy . "%_TARGETDIR%" /MIR /DST /TIMFIX /R:5
echo Last updated: %DATE% %TIME% > "%_TARGETDIR%\_LastUpdated.txt"

call "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -scan -disableremediation -scantype 3 -timeout 1 -file "%_TARGETDIR%\."

rem Restart the apps that should be running
pushd "%_TARGETDIR%"
start /d "%_TARGETDIR%" /min procexp -accepteula
start /d "%_TARGETDIR%" /min zoomit -accepteula
popd

popd
call net use /delete "%_SYSINTERNALSLIVE%" > nul 2>&1

pause
goto :EOF


:ErrorConnect
    (
        echo *** Failed to connect to %_SYSINTERNALSLIVE%.
        echo *** Try using the Windows explorer to connect first.
    ) 1>&2
    call explorer.exe "%_SYSINTERNALSLIVE%"
    pause
    exit /b 1

:ExitWithError
    popd
    pause
    exit /b 1
