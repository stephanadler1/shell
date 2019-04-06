# -----------------------------------------------------------------------
# <copyright file="base64-decoder.ps1" company="Stephan Adler">
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
Decodes base64 encoded strings into HEX and strings.
 
.DESCRIPTION
Decodes base64 encoded strings into HEX and strings. Make sure you use double quotes for the base64 encoded string if it terminates with '='.
#> 

param(
    # The base64 encode string.
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [string] $base64
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
} 

$ba = [System.Convert]::FromBase64String($base64)
$hexString = [System.BitConverter]::ToString($ba)
$string = [System.Text.Encoding]::Default.GetString($ba)

Write-Host 'hex.....:' $hexString
Write-Host 'string..:' $string