@if not defined _DEBUG echo off

if /i "%~1" equ "-help" goto ContinueAnyway
if /i "%~1" equ "version" goto ContinueAnyway
if /i "%~1" equ "-version" goto ContinueAnyway

call where kubectl > nul 2>&1
if errorlevel 1 (
    call "%~dp0aks.cmd"
    if errorlevel 1 goto :Error
)

:ContinueAnyway
setlocal

if not defined KUBE_CONFIG_PATH (
    echo *** Path to kubectl config file not set, setting it now... 1>&2
    set "KUBE_CONFIG_PATH=%USERPROFILE%\.kube\config"
)

set "__EXEPATH=%~dp0%~n0\%~n0.exe"

if not exist "%__EXEPATH%" (
    echo "%~n0" is not installed at "%__EXEPATH%". Abort.
    exit /b -1
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call "%__EXEPATH%" %*
)

goto :EOF

:Error
    (
        echo:
        echo **** SOMETHING REALLY BAD HAPPENED!
        echo:
    ) 1>&2
    exit /b 1

