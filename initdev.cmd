@if not defined _DEBUG echo off
if defined _DEBUG set "VSCMD_DEBUG=3"

:: -----------------------------------------------------------------------
:: <copyright file="initdev.cmd" company="Stephan Adler">
:: Copyright (c) Stephan Adler. All Rights Reserved.
:: </copyright>
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.
:: -----------------------------------------------------------------------

set "_WORKINGDIR=%CD%"

rem Disable isolation until .NET Standard 2.0 problem is solved
set "MSBUILD_DISABLEISOLATION=1"

rem Prefer 64 bit VS command shell
rem set "VSCMD_DEBUG=3"

rem Iterate through various Visual Studio version in priority order.
for %%v in ("Microsoft Visual Studio\2022" "Microsoft Visual Studio\2019" "Microsoft Visual Studio\2017" "Microsoft Visual Studio 14.0" "Microsoft Visual Studio 12.0" "Microsoft Visual Studio 11.0") do (
    rem Iterate through various Visual Studio editions in priority order.
    for %%e in (Preview Enterprise Community .) do (
        rem Iterate through deployment folders, prioritize x64 versions over x32.
        for %%p in ("%ProgramFiles%" "%ProgramFiles(x86)%") do (
            rem Iterate through Visual Studio command line startup scripts, in case these ever change.
            for %%t in ("Common7\Tools\VsDevCmd.bat") do (
                if exist "%%~p\%%~v\%%~e\%%~t" (
                    echo Initializing developer command prompt %%~v %%~e...
                    echo:
                    call "%%~p\%%~v\%%~e\%%~t" -arch=amd64
                    cd "%SYSTEMDRIVE%\"
                    echo:
                    goto LoadAliases
                )
            )
        )
    )
)

echo No developer command prompt found. 1>&2
echo:

if not defined TOOLS (echo TOOLS missing.)
:LoadAliases
if exist "%~dp0%~n0.doskey.alias.txt" call doskey /MACROFILE="%~dp0%~n0.doskey.alias.txt"
if exist "%~dp0%~n0.doskey.powershell.txt" call doskey /MACROFILE="%~dp0%~n0.doskey.powershell.txt"

echo COMMAND SHELL ALIASES
echo ---------------------
call doskey /macros | sort
echo:

if defined TOOLS echo GLOBAL TOOLS && echo ------------ && dir /d /l /o /a:-s-h-d "%TOOLS%\*.*" & echo:

if defined TOOLS_GIT (
    rem https://github.blog/2022-04-12-git-security-vulnerability-announced/
    if not defined GIT_CEILING_DIRECTORIES set "GIT_CEILING_DIRECTORIES=%SOURCES_ROOT%"

    echo GLOBAL GIT ALIASES
    echo ------------------
    call git config --global --get-regexp alias. | sort

    echo:
    echo GLOBAL GIT USER
    echo ---------------
    call git config --global --get-regexp user. | sort
    echo:
)

if defined SOURCES_ROOT echo REPOSITORIES && echo ------------ && dir /d /l /o /a:d "%SOURCES_ROOT%\*.*" & echo:


title Developer Shell
pushd "%_WORKINGDIR%"
set "_WORKINGDIR="

:SetCommandPrompt
if /i "%CONEMUANSI%" equ "ON" (
    set PROMPT=$E[m$E[32m$T$S$E[92m$P$E[90m$_$E[90m$G$E[m$S$E]9;12$E\
)

:SetCommonEnvironmentVariables
rem .NET environment variables are explained here:
rem https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-environment-variables
if not defined DOTNET_CLI_TELEMETRY_OPTOUT set "DOTNET_CLI_TELEMETRY_OPTOUT=1"
if not defined DOTNET_SKIP_FIRST_TIME_EXPERIENCE set "DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true"


:YourScript
if "%~1" neq "" (
    echo call "%~1"
    if exist "%~1" call "%~1"
)
