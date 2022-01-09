# -----------------------------------------------------------------------
# <copyright file="verify-connection.ps1" company="Stephan Adler">
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
    [Parameter(Mandatory = $false)]
    [ValidateNotNull()]
    [System.Uri] $address = 'http://www.msftncsi.com/ncsi.txt'
)

# https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-vista/cc766017(v=ws.10)?redirectedfrom=MSDN
# http://www.msftncsi.com/ncsi.txt

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

# Use TLS 1.2 or 1.3, don't accept anything else.
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13

# Don't check the SSL certificate, if any
[System.Net.ServicePointManager]::CheckCertificateRevocationList  = $false
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

try {
    Write-Host 'Try using Invoke-WebRequest first'
    Invoke-WebRequest -Uri $address -UseBasicParsing -ErrorAction Continue
}
catch {
    Write-Host 'Try using Invoke-RestMethod first'
    Invoke-RestMethod -Uri $address -UseBasicParsing -ErrorAction Continue
}



Write-Host 'Done.'
