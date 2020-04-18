# -----------------------------------------------------------------------
# <copyright file="random.ps1" company="Stephan Adler">
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
Generates random data.
 
.DESCRIPTION
Generates random data of the required size (in bytes) using a pRNG.
#> 

param(
    # The size/length (in bytes).
    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 4096)]
    [System.UInt16] $size,

    # Number of iterations to generate the random data.
    [Parameter(Mandatory = $false)]
    [ValidateRange(1000, 10000000)]
    [System.UInt64] $iterations = 1000000
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
} 

$script:rand = New-Object byte[] $size
$script:prng = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
try {
    for($i = 0; $i -lt $iterations; $i++) {
        $prng.GetBytes($rand)
    }

    Write-Host "Used $i iterations to generate the random data."

    $hexString = [System.BitConverter]::ToString($rand)

    Set-Clipboard -Value $hexString
    
    Write-Host
    Write-Host 'Hexadecimal Representations'
    Write-Host 'length (bytes)....:' $rand.length
    Write-Host 'hex 1.............:' $hexString.Replace('-', '')
    Write-Host 'hex 2.............:' $hexString
    Write-Host 'hex 3.............:' $hexString.Replace('-', ':')
    Write-Host 'base64............:' $([System.Convert]::ToBase64String($rand))
    
}
finally {
    $prng.Dispose()
}
