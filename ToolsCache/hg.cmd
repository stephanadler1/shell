@if not defined _DEBUG echo off
setlocal enabledelayedexpansion

if defined TOOLS (
    if exist "%TOOLS%\hg\hg.exe" (
        call "%TOOLS%\hg\hg.exe" %* < nul
        exit /b !ERRORLEVEL!
    )
)

if exist "%ProgramFiles%\Mercurial\hg.exe" (
    call "%ProgramFiles%\Mercurial\hg.exe" %* < nul
    exit /b !ERRORLEVEL!
)

call hg.exe %* < nul
exit /b !ERRORLEVEL!
