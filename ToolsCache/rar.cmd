@if not defined _DEBUG echo off
setlocal
set "_EXITCODE=1"
set "__EXEPATH=%~dp0WinRAR\%~n0.exe"
set "__EXEPATH=%~dp0WinRAR\winrar.exe"

if not exist "%__EXEPATH%" (
    echo "%~n0" is not installed at "%__EXEPATH%". Abort. 1>&2
    exit /b %_EXITCODE%
)


if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call :Invoke %* < nul
)

exit /b %_EXITCODE%

:Invoke
    call "%__EXEPATH%" %*
    set "_EXITCODE=%ERRORLEVEL%"
