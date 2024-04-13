@if not defined _DEBUG echo off
setlocal
set "__EXEPATH=%~dp0Various\fciv.exe"

if not exist "%__EXEPATH%" (
    echo "%~n0" is not installed at "%__EXEPATH%". Abort. 1>&2
    exit /b -1
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call "%__EXEPATH%" -md5 %*
)
