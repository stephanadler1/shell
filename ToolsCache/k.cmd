@if not defined _DEBUG echo off
call where kubectl > nul 2>&1
if errorlevel 1 (
    call "%~dp0aks.cmd"
    if errorlevel 1 goto :Error
)

call kubectl %* < nul
exit /b %ERRORLEVEL%


:Error
    (
        echo:
        echo **** SOMETHING REALLY BAD HAPPENED!
        echo:
    ) 1>&2
    exit /b 1

