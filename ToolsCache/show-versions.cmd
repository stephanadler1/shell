@if not defined _DEBUG echo off

setlocal

echo:
echo ==========================================================================
echo VARIOUS TOOLS
echo ==========================================================================
echo:
call dig -v
echo:
call openssl version 2>nul

echo:
echo:
echo ==========================================================================
echo LANGUAGE RUNTIMES
echo ==========================================================================

call java -version
echo:
call python2 --version
echo:
call python --version
echo:
echo Node.js
call node --version
echo:
echo NPM
call npm version

echo:
echo:
echo ==========================================================================
echo BUILD TOOLS
echo ==========================================================================
echo:

call msbuild -version
echo:
echo:
echo .NET Core
call dotnet --version
if errorlevel 1 goto Bazel
echo:
echo .NET SDKs:
call dotnet --list-sdks
echo:
echo .NET Runtimes:
call dotnet --list-runtimes
:Bazel
echo:
echo:
echo Google Bazel:
call bazel version
echo:
echo Nuget:
call nuget update -self
echo:
call nant -help

echo:
echo:
echo ==========================================================================
echo SOURCE CONTROL TOOLS
echo ==========================================================================
echo:

call git --version
echo:
call svn --version

echo:
echo ==========================================================================
echo AZURE, KUBERNETES
echo ==========================================================================
call aks > nul 2>&1
echo:

echo Azure CLI
call az version
echo:
call terraform -version
echo:
echo Helm
call helm version
echo:
echo Kubernetes kubectl
call kubectl version --client=true
echo:
call docker version
