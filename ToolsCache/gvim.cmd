@if not defined _DEBUG echo off
setlocal
set "__EXEPATH=%~dp0gvim_8.1.1436_x64\vim\vim81"
set "__EXETOOL=%~n0.exe"

if not exist "%__EXEPATH%\%__EXETOOL%" (
    echo "%~n0" is not installed at "%__EXEPATH%\%__EXETOOL%". Abort. 1>&2
    exit /b -1
)

if /i "%~1" equ "/?" (
    call start /d "%__EXEPATH%" %__EXETOOL% "/?"
) else (
    call start /d "%__EXEPATH%" %__EXETOOL% %*
)
