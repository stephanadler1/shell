@if not defined _DEBUG echo off
setlocal

if not defined TOOLS_PS (
    rem Prioritize PowerShell Core over PowerShell Desktop but if it isn't
    rem present on the machine move back to the Desktop version.
    set "TOOLS_PS=pwsh.exe"
    call where "%TOOLS_PS%" > nul 2>&1
    if errorlevel 1 set "TOOLS_PS=powershell.exe"
)

call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -command "help '%~dp0install.ps1' -full"
pause
