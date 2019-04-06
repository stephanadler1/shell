@if not defined _DEBUG echo off
if "%~1" equ "/?" (
    call "%~dp0Scripts\msbuild.cmd" "/?"
) else (
    if exist "dirs.proj" (
        call "%~dp0Scripts\msbuild.cmd" /t:slngen /nologo /consoleloggerparameters:verbosity=minimal;nosummary "dirs.proj" %* < nul
    ) else (
        call "%~dp0Scripts\msbuild.cmd" /t:slngen /nologo /consoleloggerparameters:verbosity=minimal;nosummary %* < nul
    )
)
