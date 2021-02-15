# -----------------------------------------------------------------------
# <copyright file="download-file.ps1" company="Stephan Adler">
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
Downloads a file.

.DESCRIPTION
Downloads a file from internet sources and stores it on the local file system.
#>

[CmdletBinding()]
param(
    # The URI from where to download the file.
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [System.Uri] $address,

    [Parameter(Mandatory = $false)]
    [string] $filePath = $null
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
}

if (([String]::IsNullOrWhitespace($filePath)) -and ($address.Segments.Count -ge 1)) {
    $filePath = [System.Net.WebUtility]::UrlDecode($address.Segments[$address.Segments.Count - 1])
}

Write-Host "Downloading file `"$filePath`" from `"$address`"."

$script:webClient = New-Object -TypeName 'System.Net.WebClient'

# Fake a web browser (e.g. Chrome), to bypass server checks that could otherwise throw 404 errors at you
$webClient.Headers.Add('user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36')

$webClient.DownloadFile($address, $filePath)

Write-Host 'Done.'
