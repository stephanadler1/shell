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

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

# https://learn.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
[int] $private:release = Get-ItemPropertyValue `
    -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' `
    -Name Release `
    -ErrorAction Continue
[int] $private:releaseWow = Get-ItemPropertyValue `
    -LiteralPath 'HKLM:SOFTWARE\Wow6432Node\Microsoft\NET Framework Setup\NDP\v4\Full' `
    -Name Release `
    -ErrorAction Continue
Write-Debug ".NET Framework Release number (64 bit): $release"
Write-Debug ".NET Framework Release number (32 bit): $releaseWow"

[string] $private:releaseName = '.NET Framework is not installed.'
if ($release -ge 378389)
{
    $releaseName = '.NET Framework 4.5'
}
if ($release -ge 378675)
{
    $releaseName = '.NET Framework 4.5.1'
}
if ($release -ge 379893)
{
    $releaseName = '.NET Framework 4.5.2'
}
if ($release -ge 393295)
{
    $releaseName = '.NET Framework 4.6'
}
if ($release -ge 394254)
{
    $releaseName = '.NET Framework 4.6.1'
}
if ($releaseName -ge 394802)
{
    $releaseName = '.NET Framework 4.6.2'
}
if ($release -ge 460798)
{
    $releaseName = '.NET Framework 4.7'
}
if ($release -ge 461308)
{
    $releaseName = '.NET Framework 4.7.1'
}
if ($release -ge 461808)
{
    $releaseName = '.NET Framework 4.7.2'
}
if ($release -ge 528040)
{
    $releaseName = '.NET Framework 4.8'
}
if ($release -ge 533320)
{
    $releaseName = '.NET Framework 4.8.1'
}

Write-Host $releaseName

Write-Host ([System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription)
Write-Host ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)
Write-Host ([System.Runtime.InteropServices.RuntimeInformation]::OSDescription)
Write-Host ([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture)

