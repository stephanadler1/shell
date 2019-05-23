@if not defined _DEBUG echo off
setlocal
set __EXEPATH=%~dp0node-v10.15.3-win-x64\%~n0.exe

if not exist "%__EXEPATH%" (
    echo "%~n0" is not installed at "%__EXEPATH%". Abort.
    exit /b -1
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call "%__EXEPATH%" %*
)
