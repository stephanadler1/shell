@if not defined _DEBUG echo off
call where kubectl > nul 2>&1
if errorlevel 1 (
    call "%~dp0aks.cmd"
    if errorlevel 1 goto :Error
)

call kubectl %*
goto :EOF


:Error
    echo:
    echo **** SOMETHING REALLY BAD HAPPENED!
    echo:
    exit /b 1

