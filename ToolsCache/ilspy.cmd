@if not defined _DEBUG echo off
setlocal
set "__EXEPATH=%~dp0%~n0"
set "__EXETOOL=%~n0.exe"

if not exist "%__EXEPATH%\%__EXETOOL%" (
    echo "%~n0" is not installed at "%__EXEPATH%\%__EXETOOL%". Abort. 1>&2
    exit /b -1
)

if /i "%~1" equ "/?" (
    start /d "%__EXEPATH%" %__EXETOOL% /?
) else (
    if "%~1" neq "" (
        start /d "%__EXEPATH%" %__EXETOOL% "%~f1"
    ) else (
        start /d "%__EXEPATH%" %__EXETOOL%
    )
)
