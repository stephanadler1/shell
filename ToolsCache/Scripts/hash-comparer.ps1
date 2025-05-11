# -----------------------------------------------------------------------
# <copyright file="hash-comparer.ps1" company="Stephan Adler">
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
Evaluates the hash of a file.

.DESCRIPTION
This utitily calculates the hash of a file and, if provided, compares it to the expected file hash.
If the hashes don't match an exception is thrown.
#>

[CmdletBinding()]
param(
    [string] $file,
    [string] $algorithm = 'sha256',
    [string] $expectedHash = $null
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $global:DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

$hash = Get-FileHash -algorithm $algorithm -path $file

if (($expectedHash -eq $null) -or ($expectedHash -eq ''))
{
    $hash | Format-List
    return;
}
else
{
    Import-Module -Name (Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath 'script-collection.psd1') -Scope Local -Force

    if ($null -ne (Test-FileExists $expectedHash))
    {
        $expectedHash = Get-Content -Path $expectedHash
    }

    if ($hash.Hash -ine $expectedHash)
    {
        throw "Hashes do not match! Expected is '$expectedHash' but found '$($hash.Hash)'."
    }

    Write-Host 'Success!'
}
