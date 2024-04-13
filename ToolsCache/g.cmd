@if not defined _DEBUG echo off
setlocal enabledelayedexpansion

if defined TOOLS_GIT (
    call "%TOOLS_GIT%\git" %* < nul
    exit /b !ERRORLEVEL!
)

call git %* < nul
exit /b !ERRORLEVEL!
