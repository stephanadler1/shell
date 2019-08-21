@if not defined _DEBUG echo off
setlocal

set "__EXEPATH=%~dp0jre1.8.0_211\bin"
if defined JAVA_HOME set "__EXEPATH=%JAVA_HOME%\bin"
if defined JRE_HOME set "__EXEPATH=%JRE_HOME%\bin"

set "__EXEPATH=%__EXEPATH%\%~n0.exe"

if not exist "%__EXEPATH%" (
    echo "%~n0" is not installed at "%__EXEPATH%". Abort.
    exit /b -1
)

if /i "%ConEmuANSI%" equ "ON" echo [93m^> %__EXEPATH%[0m
if /i "%ConEmuANSI%" neq "ON" echo ^> %__EXEPATH%

echo:
if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call "%__EXEPATH%" %*
)
