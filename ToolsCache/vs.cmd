@if not defined _DEBUG echo off
setlocal

where devenv.com > nul 2>&1
if errorlevel 1 (
    echo *** FATAL *** - DEVENV.COM or DEVENV.EXE was not found in the PATH. Cannot start Visual Studio. 1>&2
    exit /b 1
)

call devenv.com %*
