@if not defined _DEBUG echo off

set "__SAVEDIR=%CD%"

:: Initialize all necessary environment variables, including Visual Studio command line
call "%~dp0initdev.cmd"
cls

if not defined TOOLS_PS (
    rem Prioritize PowerShell Core over PowerShell Desktop but if it isn't
    rem present on the machine move back to the Desktop version.
    set "TOOLS_PS=pwsh.exe"
    call where "%TOOLS_PS%" > nul 2>&1
    if errorlevel 1 set "TOOLS_PS=powershell.exe"
)

pushd "%__SAVEDIR%"
set "__SAVEDIR="

set "__INITSCRIPT=%CD%\dev\init.ps1"
if not exist "%__INITSCRIPT%" (
    set "__INITSCRIPT=%~dp0initdev.ps1"
    call "%TOOLS%\aks.cmd"
)

call "%TOOLS_PS%" -NoExit -ExecutionPolicy RemoteSigned -MTA -File "%__INITSCRIPT%"
set "__INITSCRIPT="
