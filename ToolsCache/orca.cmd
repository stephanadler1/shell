@if not defined _DEBUG echo off
setlocal
set "__EXEPATH=%~dp0MsiSdkTools"
set "__EXETOOL=%~n0.exe"

if not exist "%__EXEPATH%\%__EXETOOL%" (
    echo "%~n0" is not installed at "%__EXEPATH%\%__EXETOOL%". Abort.
    exit /b -1
)

if /i "%~1" equ "help" (
    start /d "%__EXEPATH%" %~n0.chm
    goto :EOF
)

if /i "%~1" equ "/?" (
    start /d "%__EXEPATH%" %__EXETOOL% /?
) else (
    start /d "%__EXEPATH%" %__EXETOOL% %*
)
