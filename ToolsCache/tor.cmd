@if not defined _DEBUG echo off
setlocal
set "__EXEPATH=%USERPROFILE%\Desktop\Tor Browser\Browser"
set "__EXETOOL=firefox.exe"

if not exist "%__EXEPATH%\%__EXETOOL%" (
    echo "%~n0" is not installed at "%__EXEPATH%\%__EXETOOL%". Abort.
    exit /b -1
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%\%__EXETOOL%" "/?"
) else (
    call start /d "%__EXEPATH%" %__EXETOOL%
)
