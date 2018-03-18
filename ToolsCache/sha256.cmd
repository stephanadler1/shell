@if not defined _DEBUG echo off
if /i "%~1" neq "/?" (
    rem call powershell -nologo -command "Get-FileHash -algorithm sha256 -path '%1' | fl"
    call powershell -nologo -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\hash-comparer.ps1" -file "%~1" -algorithm sha256 -expectedHash "%~2"
)
