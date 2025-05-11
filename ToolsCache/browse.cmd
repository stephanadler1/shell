@if not defined _DEBUG echo off
if /i "%~1" neq "/?" (
    call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\repo-commands.ps1" -command repobrowser -currentDirectory "%CD%"
) else (
    call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -command "get-help '%~dp0scripts\repo-commands.ps1' -detailed"
)
