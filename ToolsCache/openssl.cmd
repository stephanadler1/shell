@if not defined _DEBUG echo off
setlocal
set "__EXEPATH=%~dp0%~n0.3\bin\%~n0.exe"
if not exist "%__EXEPATH%" set "__EXEPATH=%~dp0%~n0\%~n0.exe"

if not exist "%__EXEPATH%" (
    echo "%~n0" is not installed at "%__EXEPATH%". Abort. 1>&2
    exit /b -1
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call "%__EXEPATH%" %*
)
