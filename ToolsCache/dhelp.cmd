@if not defined _DEBUG echo off
setlocal
setlocal enabledelayedexpansion

if "%~1" neq "" (
    if exist "%~dp0Help\%~1.html" (
        start /D "%~dp0Help" %~ns1.html
        goto :EOF
    )

    if "%~1" equ ".." set _alternate=up
    if "%~1" equ "..." set _alternate=up
    if "%~1" equ "...." set _alternate=up
    if "%~1" equ "....." set _alternate=up

    if exist "%~dp0Help\!_alternate!.html" (
        start /D "%~dp0Help" !_alternate!.html
        goto :EOF
    )
)

echo.
more "%~dp0Help\index.txt"

goto :EOF
