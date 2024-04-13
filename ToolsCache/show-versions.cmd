@if not defined _DEBUG echo off

setlocal

echo:
echo ==========================================================================
echo OPERATING SYSTEM
echo ==========================================================================
call systeminfo

echo:
echo:
echo ==========================================================================
echo VARIOUS TOOLS
echo ==========================================================================
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Dig
call dig -v
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // OpenSSL
call openssl version 2>nul
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // zstd
call zstd -V
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // RAR
call rar v test.rar 2>nul

if exist "%~dp0Sysinternals\psversion.txt" (
    echo:
    echo //////////////////////////////////////////////////////////////////////////
    echo // Sysinternal Tools
    type "%~dp0Sysinternals\psversion.txt"
    echo:
    type "%~dp0Sysinternals\_LastUpdated.txt"
)

echo:
echo:
echo ==========================================================================
echo LANGUAGE RUNTIMES
echo ==========================================================================
echo:

echo //////////////////////////////////////////////////////////////////////////
echo // Latest .NET (Core)
call dotnet --version
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // All .NET (Core) Runtimes
call dotnet --list-runtimes
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Java Runtime Environment (JRE)
call java -version
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Python Version 2
call python2 --version
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Python Version 3
call python --version
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Node.JS
call node --version
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Node.JS Package Manager (NPM)
call npm version

echo:
echo:
echo ==========================================================================
echo BUILD TOOLS
echo ==========================================================================
echo:

echo //////////////////////////////////////////////////////////////////////////
echo // MSBuild
call msbuild -version
echo:
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // .NET (Core) SDKs
call dotnet --list-sdks
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Google Bazel
call bazel version
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Nuget
call nuget update -self
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // NAnt
call nant -help

echo:
echo:
echo ==========================================================================
echo SOURCE CONTROL TOOLS
echo ==========================================================================
echo:

echo //////////////////////////////////////////////////////////////////////////
echo // Git
call git --version
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Subversion
call svn --version
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Mercurial (HG)
call hg version

echo:
echo:
echo ==========================================================================
echo AZURE, KUBERNETES
echo ==========================================================================
call aks --version > nul 2>&1
echo:

echo //////////////////////////////////////////////////////////////////////////
echo // Azure CLI
call az version < nul
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Terraform
call terraform version 2>nul
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Helm
call helm version
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Kubernetes kubectl
call kubectl version --client=true --output=json
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Docker
call docker --version
if %ERRORLEVEL% equ 0 (
    echo:
    call docker version
)
echo:
echo //////////////////////////////////////////////////////////////////////////
echo // Windows Subsystem for Linux (WSL)
call wsl --status
if %ERRORLEVEL% equ 0 (
    echo:
    call wsl --version
    echo:
    call wsl --list --verbose
)

if exist "%~dp0..\version.txt" (
    echo:
    echo:
    echo ==========================================================================
    echo DEVELOPER SHELL VERSION
    echo ==========================================================================
    echo:
    type "%~dp0..\version.txt"
)

echo:
echo ==========================================================================
echo DONE.
echo ==========================================================================
