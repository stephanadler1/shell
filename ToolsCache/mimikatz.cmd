@echo off
setlocal
set __RUNDIR=%TEMP%\%~n0
set __EXEPATH=%TEMP%\%~n0\x64\%~n0.exe

if not exist "%__EXEPATH%" (
    md "%__RUNDIR%"  > nul 2>&1
    call "%~dp0rar.cmd" x -p123 -o+ -c- "%~dp0%~n0\%~n0.rar" "%__RUNDIR%"
)

if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
) else (
    call "%__EXEPATH%" %*
)

if errorlevel 1 (
    echo:
    echo Exclude the folder "%__RUNDIR%" from AntiVirus/Malware scanning.
)
