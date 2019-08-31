@if not defined _DEBUG echo off
setlocal
setlocal enabledelayedexpansion

set "__EXEPATH=%ProgramFiles(x86)%\WinMerge"
set "__EXETOOL=WinMergeU.exe"

if not exist "!__EXEPATH!\%__EXETOOL%" (

    set __EXEPATH=%ProgramFiles%\WinMerge

    if not exist "!__EXEPATH!\%__EXETOOL%" (
        echo "%~n0" is not installed at "!__EXEPATH!\%__EXETOOL%". Abort.
        exit /b -1
    )
)

if /i "%~1" equ "/?" (
    start /d "!__EXEPATH!" %__EXETOOL% /?
) else (
    start /d "!__EXEPATH!" %__EXETOOL% %*
)
