@if not defined _DEBUG echo off

if "%~1" equ "/?" (
    call "%~dp0Scripts\msbuild.cmd" "/?"
) else (
    call "%~dp0Scripts\msbuild.cmd" /t:rebuild "/pp:%CD%\msb-pp.xml" /consoleloggerparameters:verbosity=normal %* < nul
    echo.
    call "%~dp0Scripts\msbuild.cmd" /t:rebuild /fileLogger1 "/fileLoggerParameters1:LogFile=%CD%\msb-diag.txt;Verbosity=diagnostic;Encoding=UTF-8" /consoleloggerparameters:verbosity=normal %* < nul
)
