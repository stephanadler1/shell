# -----------------------------------------------------------------------
# <copyright file="convert-date.ps1" company="Stephan Adler">
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

.DESCRIPTION
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $global:DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

$private:separator = '****************************************************************************************'


Get-Date
[System.Security.Principal.WindowsIdentity]::GetCurrent() | Format-List
#Get-Process | Format-Table
Get-ChildItem -Path env: | Format-Table
Get-Disk | Format-List
Get-Volume | Format-Table
Get-NetAdapter | Format-List
Get-NetConnectionProfile | Format-List
#Get-NetIPAddress
Get-NetIPConfiguration | Format-List
#Get-NetFirewallProfile

Test-NetConnection



Write-Host
Write-Host $separator
Write-Host
