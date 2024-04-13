@if not defined _DEBUG echo off
setlocal
set "__EXEPATH=%~dp0npp"
set "__EXETOOL=notepad++.exe"

if not exist "%__EXEPATH%\%__EXETOOL%" (
    echo "%~n0" is not installed at "%__EXEPATH%\%__EXETOOL%". Abort. 1>&2
    exit /b -1
)

if /i "%~1" equ "/?" (
    pushd "%__EXEPATH%"
    start /d "%CD%" %__EXETOOL% /?
) else (
	tasklist | findstr /ic:"%__EXETOOL%" > nul 2>&1
	if errorlevel 1 (
        pushd "%__EXEPATH%"
		start /d "%CD%" %__EXETOOL%
		call choice /t 1 /c yn /d y > nul 2>&1
        popd
	)
    call "%__EXEPATH%\%__EXETOOL%" %*
)
