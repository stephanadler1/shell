@if not defined _DEBUG echo off



if /i "%~1" equ "/?" goto ShowHelp
if /i "%~1" equ ""   goto ShowHelp

if /i "%~1" equ "on" (
    call "%~dp0toggle-status.cmd" "on"
    goto :EOF
) else (
    call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\presence-light.ps1" -status "%~1"
    goto :EOF
)


:ShowHelp
    call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -command "get-help '%~dp0scripts\presence-light.ps1' -detailed"
    goto :EOF
