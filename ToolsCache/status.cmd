@if not defined _DEBUG echo off

if /i "%~1" neq "/?" (
    if /i "%~1" equ "on" (
        call "%~dp0toggle-status.cmd" "on"
        goto :EOF
    ) else (
        call powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\presence-light.ps1" -status "%~1"
        goto :EOF
    )
) else (
    call powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -command "get-help '%~dp0scripts\presence-light.ps1' -detailed"
)
