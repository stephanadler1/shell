# -----------------------------------------------------------------------
# <copyright file="encode-base64.ps1" company="Stephan Adler">
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
Encodes strings into their base64 representation.

.DESCRIPTION
Encodes strings into their base64 representation.
#>

[CmdletBinding()]
param(
    # The text string to encode.
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [string] $text
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

$utf8Base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($text))
$asciiBase64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($text))

Set-Clipboard -Value $utf8Base64

Write-Host
Write-Host 'String Representations'
Write-Host 'as UTF-8..........:' $utf8Base64
Write-Host 'as ASCII..........:' $asciiBase64
