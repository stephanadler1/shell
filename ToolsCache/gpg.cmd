@if not defined _DEBUG echo off
setlocal

call "%~dp0Scripts\gnupg.cmd"
if errorlevel 1 exit /b 1

set "__EXETOOL=%~n0.exe"

if not exist "%__EXEPATH%\%__EXETOOL%" (
    echo "%~n0" is not installed at "%__EXEPATH%\%__EXETOOL%". Abort. 1>&2
    exit /b -1
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%\%__EXETOOL%" "/?"
) else (
    call "%__EXEPATH%\%__EXETOOL%" %*
)
