@if not defined _DEBUG echo off

:: Opens the tools directory in the Visual Studio Code (VS Code) editor. If VS Code is not installed,
:: it changes the current directory to it instead.
if not exist "%USERPROFILE%\.kube" goto :EOF

call where code > nul 2>&1
if errorlevel 1 (
    pushd "%USERPROFILE%\.kube"
    exit /b 1
)

call code "%USERPROFILE%\.kube"
if defined KUBECONFIG call "%~dp0.\n.cmd" "%KUBECONFIG%"
