@if not defined _DEBUG echo off
setlocal
set "MSBUILD_ENABLELOGGING=1"
if "%~1" equ "/?" (
    call "%~dp0Scripts\msbuild.cmd" "/?"
) else (
    call "%~dp0msb.cmd" /t:rebuild "/pp:%CD%\msb-pp.xml" %* < nul
    call "%~dp0bcc.cmd" %* < nul
)
