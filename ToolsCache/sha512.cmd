@if not defined _DEBUG echo off
if /i "%~1" neq "/?" (
    call powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\hash-comparer.ps1" -file "%~1" -algorithm sha512 -expectedHash "%~2"
) else (
    call powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -command "get-help '%~dp0scripts\hash-comparer.ps1' -detailed"
)
