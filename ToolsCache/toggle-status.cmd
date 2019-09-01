@if not defined _DEBUG echo off

setlocal
set "_SEMFILE=%TEMP%\presence-light-busy.txt"

if /i "%~1" equ "on" (
    if exist "%_SEMFILE%" (
        if defined _DEBUG echo DEBUG: Semaphore file found, status is 'busy'.
        call "%~dp0status.cmd" busy
        goto :EOF
    )
    if not exist "%_SEMFILE%" (
        if defined _DEBUG echo DEBUG: Semaphore file not found, status is 'available'.
        call "%~dp0status.cmd" available
        goto :EOF
    )
) else (
    if exist "%_SEMFILE%" (
        if defined _DEBUG echo DEBUG: Semaphore file found, status will change to 'available'.
        del /f /q "%_SEMFILE%" 
        call "%~dp0status.cmd" available
        goto :EOF
    )

    if not exist "%_SEMFILE%" (
        if defined _DEBUG echo DEBUG: Semaphore file not found, status will change to 'busy'.
        echo busy > "%_SEMFILE%" 
        call "%~dp0status.cmd" busy 
        goto :EOF
    )
)

