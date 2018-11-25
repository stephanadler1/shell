@if not defined _DEBUG echo off
if exist "%~dp0%~n0" (
    call explorer "%~dp0%~n0"
) else (
    call "%~dp0dhelp.cmd" "%~n0"
)
