@if not defined _DEBUG echo off
if /i "%~1" neq "/?" (
    call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -sta -file "%~dp0scripts\get-publicip.ps1" %*
) else (
    call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -command "get-help '%~dp0scripts\get-publicip.ps1' -detailed"
)
