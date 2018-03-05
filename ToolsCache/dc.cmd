@if not defined _DEBUG echo off
setlocal
set __EXEPATH=%~dp0Scripts
set __EXETOOL=DeveloperConsole.msc

if not exist "%__EXEPATH%\%__EXETOOL%" (
    echo "%~n0" is not installed at "%__EXEPATH%\%__EXETOOL%". Abort.
    exit /b -1
)

if /i "%~1" equ "/?" (
    start /d "%__EXEPATH%" %__EXETOOL% /?
) else (
    start /d "%__EXEPATH%" %__EXETOOL%
)
