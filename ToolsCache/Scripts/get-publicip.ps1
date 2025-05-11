# -----------------------------------------------------------------------
# <copyright file="get-publicip.ps1" company="Stephan Adler">
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
Get your public IPv4 address.

.DESCRIPTION
This utitily attempts to retrieve your public IPv4 address.
#>


Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $global:DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

$private:rootPath = Split-Path $script:MyInvocation.MyCommand.Path -Parent
$private:libPsmRoot = Join-Path -Path $rootPath -ChildPath 'psm'
$private:libPsModules = @('network\Parsifal.Network.psd1')
$libPsModules | ForEach-Object {
    Import-Module -Name (Join-Path -Path $libPsmRoot -ChildPath $_) -Scope Local
}

if ('Continue' -ieq $DebugPreference) {
    Get-Module | ForEach-Object {
        Write-Debug "$($_.Name) $($_.Version)"
    }
}

Write-Host $(Get-ExternalIpAddress -useCache)
