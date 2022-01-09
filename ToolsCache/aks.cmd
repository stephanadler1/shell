@if not defined _DEBUG echo off

echo:
echo Validating Azure CLI is installed...
call where az > nul 2>&1
if errorlevel 1 goto ErrorAzureCliOrKubeCtlMissing

echo Ensure Azure CLI is working...
call az --version > nul 2>&1
if errorlevel 1 goto ErrorAzureCliOrKubeCtlMissing

echo Validating KubeCtl is installed...
call where kubectl > nul 2>&1
if errorlevel 1 (
    rem if it is not already on the path, it's default installation location
    rem when done through Azure CLI is in 'C:\Users\Stephan\.azure-kubectl'.
    rem Let's assume it is supposed to be there.

    echo Adding KubeCtl to PATH...
    if not exist "%USERPROFILE%\.azure-kubectl" goto ErrorAzureCliOrKubeCtlMissing
    set "PATH=%PATH%;%USERPROFILE%\.azure-kubectl"
)


echo Ensure KubeCtl is working...
call kubectl version --client=true > nul 2>&1
if errorlevel 1 goto ErrorAzureCliOrKubeCtlMissing

if not defined KUBE_CONFIG_PATH set "KUBE_CONFIG_PATH=%USERPROFILE%\.kube\config"


echo Ensure Docker CLI is working...
call docker version > nul 2>&1
if errorlevel 1 call :ErrorDockerCliMissing


rem title Azure ^& Kubernetes

rem http://www.patorjk.com/software/taag/#p=display&f=Larry%203D&t=Kubernetes
echo:
echo     /\
echo    /  \    _____   _ _  ___ _
echo   / /\ \  ^|_  / ^| ^| ^| \'__/ _\
echo  / ____ \  / /^| ^|_^| ^| ^| ^|  __/
echo /_/    \_\/___^|\__,_^|_^|  \___^|
echo      __  __           __                                    __
echo     /\ \/\ \         /\ \                                  /\ \__
echo     \ \ \/'/'  __  __\ \ \____     __   _ __    ___      __\ \ ,_\    __    ____
echo      \ \ , ^<  /\ \/\ \\ \ '__`\  /'__`\/\`'__\/' _ `\  /'__`\ \ \/  /'__`\ /',__\
echo       \ \ \\`\\ \ \_\ \\ \ \L\ \/\  __/\ \ \/ /\ \/\ \/\  __/\ \ \_/\  __//\__, `\
echo        \ \_\ \_\ \____/ \ \_,__/\ \____\\ \_\ \ \_\ \_\ \____\\ \__\ \____\/\____/
echo         \/_/\/_/\/___/   \/___/  \/____/ \/_/  \/_/\/_/\/____/ \/__/\/____/\/___/
echo:
echo           IS READY!
echo:

goto :EOF

:ErrorAzureCliOrKubeCtlMissing
    echo:
    echo *** YOU NEED TO INSTALL THE AZURE CLI AND KUBECTL
    echo *** https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
    echo *** https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster#install-the-kubernetes-cli
    echo:
    exit /b 1

:ErrorDockerCliMissing
    echo:
    echo *** Docker CLI not found!
    echo:
    goto :EOF
