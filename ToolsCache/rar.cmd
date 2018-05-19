@echo off
setlocal
set __EXEPATH=%~dp0WinRAR\%~n0.exe

if not exist "%__EXEPATH%" (
    echo "%~n0" is not installed at "%__EXEPATH%". Abort.
    exit /b -1
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call "%__EXEPATH%" %*
)