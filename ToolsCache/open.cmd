@if not defined _DEBUG echo off
setlocal
set "__EXEPATH=%~dp0Microsoft.SlnGen.1.1.3351.1\tools\slngen.exe"

if not exist "%__EXEPATH%" (
    echo "%~n0" is not installed at "%__EXEPATH%". Abort.
    exit /b -1
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call "%__EXEPATH%" %*
)