@if not defined _DEBUG echo off
setlocal
call "%~dp0Scripts\node.cmd"
set "__EXEPATH=%__NODEPATH%\%~nx0"

if not exist "%__EXEPATH%" (
    call npm install -g "%~n0"
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call "%__EXEPATH%" %*
    exit /b %ERRORLEVEL%
)
