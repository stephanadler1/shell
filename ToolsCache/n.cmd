@if not defined _DEBUG echo off
setlocal
set "__EXEPATH=%~dp0npp.7.9.2.portable.x64"
set "__EXETOOL=notepad++.exe"

if not exist "%__EXEPATH%\%__EXETOOL%" (
    echo "%~n0" is not installed at "%__EXEPATH%\%__EXETOOL%". Abort.
    exit /b -1
)

if /i "%~1" equ "/?" (
    call start /d "%__EXEPATH%" %__EXETOOL% /?
) else (
	tasklist | findstr /ic:"%__EXETOOL%" > nul 2>&1
	if errorlevel 1 (
		call start /d "%__EXEPATH%" %__EXETOOL%
		call choice /t 1 /c yn /d y > nul 2>&1
	)
    call "%__EXEPATH%\%__EXETOOL%" %*
)
