set "__GNUPATH=%~dp0..\..\..\Documents\gpg4win.portable"
if not exist "%__GNUPATH%" if defined TOOLS      set "__GNUPATH=%TOOLS%\..\..\Documents\gpg4win.portable"
if not exist "%__GNUPATH%" if defined TOOLS_ORIG set "__GNUPATH=%TOOLS_ORIG%\..\Documents\gpg4win.portable"
if not exist "%__GNUPATH%" set "__GNUPATH=%~dp0..\gpg4win.portable"

set "__GNUPATH=%TOOLS_ORIG%\..\Documents\gpg4win.portable.4.0.3"
set "__GNUPATH=%TOOLS_ORIG%\..\Documents\gpg4win.portable.4.1.0"
rem Workaround to fix a behavior in how the socket is being determined in the
rem portable version. It requires a GNUPG folder next to HOME!
rem See https://github.com/ScoopInstaller/Main/issues/2599 for details.
md "%__GNUPATH%\gnupg" >nul 2>&1

set "__EXEPATH=%__GNUPATH%\bin"

rem GNUPGHOME environment variable has no impact on portable deployments.
rem set GNUPGHOME=%__GNUPATH%\home

if not exist "%__GNUPATH%" (
    echo GNU Privacy Guard is not installed at "%__GNUPATH%". Abort. 1>&2
    exit /b 1
)

exit /b 0
