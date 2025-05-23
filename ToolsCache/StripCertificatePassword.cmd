@if not defined _DEBUG echo off
setlocal
if /i "%~1" neq "/?" (
    call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\%~n0.ps1" %*
    if errorlevel 1 (
        echo Exit code ^> 0 doesn't indicate success. 1>&2
        exit /b 1
    )
) else (
    call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -command "get-help '%~dp0scripts\%~n0.ps1' -detailed"
)
