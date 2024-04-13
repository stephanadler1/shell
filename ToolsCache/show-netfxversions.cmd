@if not defined _DEBUG echo off
if /i "%~1" neq "/?" (
    call powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\%~n0.ps1" %*
) else (
    call powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -command "get-help '%~dp0scripts\%~n0.ps1' -detailed"
)
exit /b 0
