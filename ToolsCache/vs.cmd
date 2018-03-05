@if not defined _DEBUG echo off
setlocal

where devenv > nul 2>&1
if errorlevel 1 (
    echo *** FATAL *** - DEVENV.COM or DEVENV.EXE was not found in the PATH. Cannot start Visual Studio.
    exit /b 1
)

call devenv %*
