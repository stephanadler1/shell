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
    $DebugPreference = 'Continue'
}

try {
    [string] $private:checkIpResult = Invoke-WebRequest -Uri 'http://checkip.dyndns.org:8245/' -Method Get `
        -MaximumRedirection 0 -UseBasicParsing -Timeout 2 `
        -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36'
    Write-Debug "Full result..: $checkIpResult"

    $private:checkIpParsed = Select-String -Pattern "(Current IP Address: )([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})" -InputObject $checkIpResult

    if (($null -eq $checkIpParsed.Matches) -and ($checkIpParsed.Matches.Groups.Length -ne 2))
    {
        throw "No IP address found in '$checkIpResult'."
    }

    Write-Debug "IP address...: $($checkIpParsed.Matches.Groups[2])"

    return $checkIpParsed.Matches.Groups[2].Value
}
finally {
    # No op
}


try {
    [string] $private:checkIpResult = Invoke-WebRequest -Uri 'https://checkip.amazonaws.com/' -Method Get `
        -MaximumRedirection 0 -UseBasicParsing -Timeout 5 `
        -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36'
    Write-Debug "Full result..: $checkIpResult"

    $private:checkIpParsed = Select-String -Pattern "([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})" -InputObject $checkIpResult

    if (($null -eq $checkIpParsed.Matches) -and ($checkIpParsed.Matches.Groups.Length -ne 1))
    {
        throw "No IP address found in '$checkIpResult'."
    }

    Write-Debug "IP address...: $($checkIpParsed.Matches.Groups[1])"

    return $checkIpParsed.Matches.Groups[1].Value
}
finally {
    # No op
}
