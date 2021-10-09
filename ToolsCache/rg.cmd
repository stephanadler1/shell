@if not defined _DEBUG echo off
if /i "%~1" neq "/?" (
    call powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\repo-commands.ps1" -command revisiongraph -currentDirectory "%CD%"
) else (
    call powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -command "get-help '%~dp0scripts\repo-commands.ps1' -detailed"
)
