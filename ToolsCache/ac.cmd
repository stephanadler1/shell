@if not defined _DEBUG echo off
setlocal
set "_currentdir=%~1"
if not defined _currentdir set "_currentdir=%CD%"

if /i "%~1" neq "/?" (
    call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\repo-commands.ps1" -command log -currentDirectory "%_currentdir%"
) else (
    call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -command "get-help '%~dp0scripts\repo-commands.ps1' -detailed"
)
