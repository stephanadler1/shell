@if not defined _DEBUG echo off
if "%~1" equ "/?" (
    call "%~dp0Scripts\msbuild.cmd" "/?"
) else (
    call "%~dp0Scripts\msbuild32.cmd" /t:restore %* < nul
)

