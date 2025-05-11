@echo off
setlocal
set "__RUNDIR=%TEMP%\9f1493b7-22ca-4a75-bb7a-a6f39a5dd76e\d6bdec38e012455d8a521127e0557bea"
set "__EXEPATH=%__RUNDIR%\x64\mimikatz.exe"

if not exist "%__EXEPATH%" (
    md "%__RUNDIR%"  > nul 2>&1
    call "%~dp0rar.cmd" x -p123 -o+ -c- "%~dp0d6bdec38e012455d8a521127e0557bea\d6bdec38e012455d8a521127e0557bea.rar" "%__RUNDIR%"
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call "%__EXEPATH%" %*
)

if errorlevel 1 (
    (
        echo:
        echo Exclude the folder "%__RUNDIR%" from AntiVirus/Malware scanning. Run
        echo:
        echo    pwsh -nologo -noprofile -executionPolicy RemoteSigned -command "Set-MpPreference -ExclusionPath '%__RUNDIR%'"
        echo:
        echo  or
        echo:
        echo    Set-MpPreference -ExclusionPath '%__RUNDIR%'
        echo Set-MpPreference -ExclusionPath '%__RUNDIR%' | clip > nul 2>&1
        echo:
        echo from an elevated command prompt to configure Windows Defender.
    ) 1>&2
)
