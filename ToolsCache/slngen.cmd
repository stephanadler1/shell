@if not defined _DEBUG echo off
if /i "%~1" neq "/?" (
    call powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\%~n0.ps1" -currentDirectory "%CD% %*
) else (
    call powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -command "get-help '%~dp0scripts\%~n0.ps1' -detailed"
)
exit /b 0


@if not defined _DEBUG echo off

if "%~1" equ "/?" (
    call "%~dp0Scripts\msbuild.cmd" "/?"
) else (
    if exist "dirs.proj" (
        call "%~dp0Scripts\msbuild32.cmd" /restore:true /t:slngen /nologo /consoleloggerparameters:verbosity=minimal;nosummary "dirs.proj" %* < nul
    ) else (
        call "%~dp0Scripts\msbuild32.cmd" /restore:true /t:slngen /nologo /consoleloggerparameters:verbosity=minimal;nosummary %* < nul
    )
    if errorlevel 1 (
        if exist "%~dp0slngen\slngen.exe" (
            if exist "dirs.proj" (
                call "%~dp0slngen\slngen.exe" --nologo "dirs.proj" %* < nul
            ) else (
                call "%~dp0slngen\slngen.exe" --nologo %* < nul
            )
        )
    )
)

exit /b 0


if "%~1" equ "/?" (
    call "%~dp0slngen\slngen.exe" "/?"
) else (
    if exist "dirs.proj" (
        call "%~dp0slngen\slngen.exe" --nologo "dirs.proj" %* < nul
    ) else (
        call "%~dp0slngen\slngen.exe" --nologo %* < nul
    )
)
