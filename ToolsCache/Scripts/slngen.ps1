# -----------------------------------------------------------------------
# <copyright file="slngen.ps1" company="Stephan Adler">
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

[CmdletBinding()]
param(
    # The working directory for MSBuild.
    [Parameter(Mandatory = $true)]
    [ValidateScript({[System.IO.Directory]::Exists($_) -eq $true})]
    [string] $currentDirectory,

    # The project name to start generating the solution from.
    [Parameter(Mandatory = $false)]
    [string] $projectName = 'dirs.proj'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $global:DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

$private:scriptPath = (Split-Path -Parent $PSCommandPath)
Import-Module -Name (Join-Path -Path $scriptPath -ChildPath 'script-collection.psd1') -Scope Local -Force


$script:workingCopyRoot = (Get-WorkingCopyRootPath)
Write-Debug "Working copy root is at $workingCopyRoot"


if (-not [IO.File]::Exists([IO.Path]::Combine($workingCopyRoot, "CloudBuild.json")))
{
    Write-Debug 'Using MSBuild to create the solution file.'

    $private:msbuildArgs = @(
        '/restore:true',
        '/t:slngen',
        '/nologo',
        '/consoleloggerparameters:verbosity=minimal;nosummary',
        $projectName
    )

    $private:msbuildTool = ([IO.Path]::Combine($scriptPath, 'msbuild32.cmd'))
    Write-Debug "MSBuild tool path is $msbuildTool"

    & $msbuildTool $msbuildArgs
    if ($LASTEXITCODE -eq 0)
    {
        exit 0
        return
    }
}

Write-Debug 'Use SlnGen to create the solution file.'

$private:slnGenTool = [IO.Path]::Combine($env:USERPROFILE, '.dotnet', 'tools', 'slngen.exe')
$private:slnGenArgs = @(
    '--nologo',
    $projectName
)

Write-Debug "SlnGen tool path is $slnGenTool"

if (-not [IO.File]::Exists($slnGenTool))
{
    # Install SlnGen if its not installed
    Write-Host "Installing SlnGen..."
    & 'dotnet.exe' @('tool', 'install', '--global', 'Microsoft.VisualStudio.SlnGen.Tool', '--add-source', 'https://api.nuget.org/v3/index.json', '--ignore-failed-sources')
}

& $slnGenTool $slnGenArgs

exit $LASTEXITCODE


