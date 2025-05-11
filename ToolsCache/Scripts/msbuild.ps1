# -----------------------------------------------------------------------
# <copyright file="msbuild.ps1" company="Stephan Adler">
# Copyright (c) Stephan Adler. All Rights Reserved.
# </copyright>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# -----------------------------------------------------------------------

<#
.SYNOPSIS
This script invokes MSBuild.exe with the provided command line arguments.

.DESCRIPTION
This script invokes MSBuild.exe with the provided command line arguments.
It searches for a version of MSBuild in the following locations:

 1. In the MSBUILD environment variable
 2. In the directories that the PATH environment variable lists
 3. In the amd64 subfolder of a found MSBuild installation, if prefer64Bit is set.

If environment variable MSBUILD_ENABLELOGGING is defined, enables file based logging for
errors, warnings and diagnostics output.

If environment variable MSBUILD_DISABLEISOLATION is NOT defined, the MSBuild process runs
in isolation mode to detect if the build tries to leverage random executable through the
PATH environment variables or otherwise tries to break out of a well-defined sandbox.
#>

[CmdletBinding()]
param(
    # Arguments being passed through to MSBuild.
    [Parameter(Mandatory = $true)]
    [string] $msbuildArgs,

    # The working directory for MSBuild.
    [Parameter(Mandatory = $true)]
    [ValidateScript({[System.IO.Directory]::Exists($_) -eq $true})]
    [string] $currentDirectory,

    # If defined, lower the priority of the MSBuild process to keep the machine responsive for the user during the build.
    [Parameter(Mandatory = $false)]
    [switch] $lowerPriority,

    # If defined uses the 64 bit MSBuild image if available.
    [Parameter(Mandatory = $false)]
    [switch] $prefer64Bit,

    # If defined uses the text-based diagnostic log instead of binary logging.
    [Parameter(Mandatory = $false)]
    [switch] $preferTextDiagnosticLog
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $global:DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

if (($PSVersionTable.PSVersion -ge '7.3') -and ($IsWindows -eq $true))
{
    $script:PSNativeCommandArgumentPassing = 'Legacy'
    Write-Debug "Setting PSNativeCommandArgumentPassing to $PSNativeCommandArgumentPassing."
}

Import-Module -Name (Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath 'script-collection.psd1') -Scope Local -Force

# Get the initial MSBuild location from the environment.
[string] $script:msbuildTool = $env:MSBUILD
[string] $script:msbuildTool64 = $null

# Calculate the number of parallelism based on the number of cores available on the system.
# Just using msbuild /m underutilizes the system.
[int] $script:parallalism = [int]::Parse($env:NUMBER_OF_PROCESSORS) * 2

# Check if additional logging to files is requested.
[bool] $script:isLoggingEnabled = ([System.String]::IsNullOrEmpty($env:MSBUILD_ENABLELOGGING) -eq $false)

# Check if build isolation is requested.
[bool] $script:isIsolationEnabled = ([System.String]::IsNullOrEmpty($env:MSBUILD_DISABLEISOLATION) -eq $true)

# Check if debug logging is enabled.
[bool] $script:isDebugEnabled = ([System.String]::IsNullOrEmpty($env:_DEBUG) -eq $false)

# The default arguments always passed into msbuild.exe.
# /m - multi-processor build
# /nr:false - turn off node re-use
# /low:true - Runs MSBuild in at low process priority (instead of $lowerPriority in this script!)
[array] $script:defaultArgs = @("/m:$parallalism", '/nr:false')
if ([string]::IsNullOrWhitespace($env:MSBUILD_ARGS) -eq $false)
{
    $defaultArgs += $env:MSBUILD_ARGS.Split(' ')
}

# Logging file path prefix
[string] $script:loggingFilePath = [System.IO.Path]::Combine($currentDirectory, 'msbuild-')

# Defining the priority class for the MSBuild process
[System.Diagnostics.ProcessPriorityClass] $script:priorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal
if ($lowerPriority)
{
    $priorityClass = [System.Diagnostics.ProcessPriorityClass]::BelowNormal
}

#Import-Module -Name (Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath 'script-collection.psd1') -Scope Local -Force

Write-Host
Write-Host 'Started' ([System.DateTime]::Now)

function SetupIsolation
{
    [string] $tempPath = [System.IO.Path]::Combine($env:TEMP, 'wtf')
    [string] $path = [System.IO.Path]::Combine($tempPath, 'VGhpc0lz')

    Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path $path -ItemType Directory | Out-Null

    [System.Environment]::SetEnvironmentVariable('INCLUDE', $path, [System.EnvironmentVariableTarget]::Process)
    [System.Environment]::SetEnvironmentVariable('LIB', $path, [System.EnvironmentVariableTarget]::Process)
    [System.Environment]::SetEnvironmentVariable('PATH', $path, [System.EnvironmentVariableTarget]::Process)
    [System.Environment]::SetEnvironmentVariable('TEMP', $tempPath, [System.EnvironmentVariableTarget]::Process)
    [System.Environment]::SetEnvironmentVariable('TMP', $tempPath, [System.EnvironmentVariableTarget]::Process)

    Write-Host
    Write-Host '*** BUILD ISOLATION ACTIVE ***'
    Write-Host 'To disable isolation mode, set MSBUILD_DISABLEISOLATION=1 or run toggle-msbuildisolation'
    Write-Host 'INCLUDE  =' $env:INCLUDE
    Write-Host 'LIB      =' $env:LIB
    Write-Host 'PATH     =' $env:PATH
    Write-Host 'TEMP/TMP =' $env:TEMP
    Write-Host '******************************'
}

function ReportIsolation
{
    $files = Get-ChildItem -Path $env:TEMP -Recurse -File
    if ($files)
    {
        try {
            $count = $files.Count + ' files'
        }
        catch {
            $count = '1 file'
        }

        Write-Host
        Write-Host '*** FILES HAVE BEEN WRITTEN OUTSIDE OF BUILD OUTPUT ***' -ForegroundColor Red
        Write-Host $count 'have been found.' -ForegroundColor Red
        Write-Host 'Use the following command to list them:'
        Write-Host "  dir /b /s /a:-d `"$env:TEMP`""

        [string] $clipTool = "$($env:SYSTEMROOT)\system32\clip.exe"
        if ([System.IO.File]::Exists($clipTool))
        {
            "dir /b /s /a:-d `"$env:TEMP`"" | & $clipTool
            Write-Host 'This command has been pasted to the clipboard.'
            Write-Host "Get-ChildItem -Path '$env:TEMP' -Recurse -File"
        }

        Write-Host '*******************************************************' -ForegroundColor Red
        Write-Host
    }
}


$msbuildTool = Test-FileExists($msbuildTool)
if ([System.String]::IsNullOrEmpty($msbuildTool) -eq $true)
{
    & where.exe msbuild /q | Out-Null
    if ($LASTEXITCODE -ne 0)
    {
        Write-Error 'msbuild.exe was not found on the system. Either make it part of the PATH environment variable or create an environment variable MSBUILD to point to the version you wish to use.'
        [System.Environment]::Exit(1)
        exit 1
    }

    $msbuildTools = & where.exe msbuild
    if ($msbuildTools -is [array])
    {
        $msbuildTool = $msbuildTools[0]
    }
    else
    {
        $msbuildTool = $msbuildTools
    }

    $msbuildTool = Test-FileExists($msbuildTool)
}

if ([System.String]::IsNullOrEmpty($msbuildTool) -eq $false)
{
    $msbuildTool64 = Test-FileExists([System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($msbuildTool), 'amd64', [System.IO.Path]::GetFileName($msbuildTool)))
    if (([System.String]::IsNullOrEmpty($msbuildTool64) -eq $false) -and $prefer64Bit)
    {
        $msbuildTool = $msbuildTool64
    }
}

$script:arguments = $defaultArgs

if ($isLoggingEnabled)
{
    if (-not $preferTextDiagnosticLog)
    {
        $arguments += @("/bl:LogFile=`"$($loggingFilePath)log.binlog`";ProjectImports=None")
    }

    $arguments += @(
        "/flp:LogFile=`"$($loggingFilePath)diag.txt`";Encoding=UTF-8;Verbosity=Diagnostic",
        "/flp1:LogFile=`"$($loggingFilePath)errors.txt`";Encoding=UTF-8;ErrorsOnly",
        "/flp2:LogFile=`"$($loggingFilePath)warnings.txt`";Encoding=UTF-8;WarningsOnly",
        "/ds")
}

$arguments += $msbuildArgs.Split(' ');

if ([System.String]::IsNullOrEmpty($env:_DEBUG) -eq $false)
{
    Write-Host
    Write-Host '*** DEBUG DATA ***'
    Write-Host 'msbuildTool.........:' $msbuildTool
    Write-Host 'msbuildTool64.......:' $msbuildTool64
    Write-Host 'isLoggingEnabled....:' $isLoggingEnabled
    Write-Host 'isIsolationEnabled..:' $isIsolationEnabled
    Write-Host 'parallalism.........:' $parallalism
    Write-Host 'combined arguments..:' $arguments
    Write-Host 'msbuildargs.........:' $msbuildArgs
    Write-Host 'defaultArgs.........:' $defaultArgs
    Write-Host 'currentDirectory....:' $currentDirectory
    Write-Host 'Prefer64Bit tool....:' $prefer64Bit
    Write-Host '******************'

}

Remove-Item -Path "$loggingFilePath*.txt" -Recurse -Force
Remove-Item -Path "$loggingFilePath*.binlog" -Recurse -Force

if ($script:isIsolationEnabled)
{
    SetupIsolation
}

[System.Diagnostics.Process] $process = New-Object -TypeName 'System.Diagnostics.Process'
[int] $msbuildExitCode = 1

$startInfo = $process.StartInfo
$startInfo.CreateNoWindow = $false
$startInfo.FileName = $msbuildTool
$startInfo.UseShellExecute = $false
$startInfo.Arguments = $arguments
$startInfo.WorkingDirectory = $currentDirectory
$startInfo.LoadUserProfile = $false

Write-Host
Write-Host "> `"$msbuildTool`" $arguments" -ForegroundColor Yellow
#Write-Host

$started = $process.Start()
if ($started)
{
    $process.PriorityClass = $priorityClass
    #$process.WaitForExit()
    # related to https://github.com/dotnet/msbuild/issues/2269
    Wait-Process -InputObject $process
    $msbuildExitCode = $process.ExitCode
}

$process.Dispose()

if ($script:isIsolationEnabled)
{
    ReportIsolation
}


Write-Host
Write-Host 'Ended' ([System.DateTime]::Now)

$host.SetShouldExit($msbuildExitCode)
[System.Environment]::Exit($msbuildExitCode)
exit $msbuildExitCode
