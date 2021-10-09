@if not defined _DEBUG echo off
setlocal
call "%~dp0Scripts\node.cmd"
if errorlevel 1 call "%TOOLS%\Scripts\node.cmd"
set "__EXEPATH=%__NODEPATH%\%~n0.exe"

if not exist "%__EXEPATH%" (
    echo "%~n0" is not installed at "%__EXEPATH%". Abort.
    exit /b 1
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call "%__EXEPATH%" %*
    exit /b %ERRORLEVEL%
)
