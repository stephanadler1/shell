@if not defined _DEBUG echo off

if "%~1" equ "" (
    doskey /macros | sort
) else (
    doskey /macros | findstr /i /r "^%~1" | sort
)