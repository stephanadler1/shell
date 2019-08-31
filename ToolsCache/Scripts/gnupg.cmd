set "__GNUPATH=%~dp0..\..\..\Documents\gpg4win.portable"
if not exist "%__GNUPATH%" set __GNUPATH=%~dp0..\gpg4win.portable
set "__EXEPATH=%__GNUPATH%\bin"

rem GNUPGHOME environment variable has no impact on portable deployments.
rem set GNUPGHOME=%__GNUPATH%\home

if not exist "%__GNUPATH%" (
    echo GNU Privacy Guard is not installed at "%__GNUPATH%". Abort.
    exit /b 1
)
exit /b 0
