# -----------------------------------------------------------------------
# <copyright file="quickbuild.ps1" company="Stephan Adler">
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
    # Arguments being passed through to MSBuild.
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $productVersion = "Windows 10",

    # The working directory for MSBuild.
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $targetReleaseVersionInfo = "21H2"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $global:DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

[string] $path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\TargetReleaseVersion'
Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\TargetReleaseVersion
[int] $private:currTargetReleaseVersion = Get-Item -Path $path -Include TargetReleaseVersion
[string] $private:currProductVersion = Get-Item -Path $path -Include ProductVersion
[string] $private:currTargetReleaseVersionInfo = Get-Item -Path $path -Include TargetReleaseVersionInfo

Write-Host $currTargetReleaseVersion
Write-Host $currProductVersion
Write-Host $currTargetReleaseVersionInfo

