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

[CmdletBinding()]
param(
    # The date and time
    [Parameter(Mandatory = $false)]
    [string] $timeString
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $global:DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

Write-Host

$date = [System.DateTimeOffset]::Now
if (-not ([System.String]::IsNullOrWhitespace($timeString)))
{
    [string] $parsingType = '<Unkown>'

    # Try first to see if it is a valid number that can be parsed
    [System.UInt64] $timeValue = 0
    if ([System.UInt64]::TryParse($timeString, [System.Globalization.NumberStyles]::Integer, $null, [ref] $timeValue))
    {
        try
        {
            $parsingType = 'UNIXTIME'
            $date = [System.DateTimeOffset]::FromUnixTimeSeconds($timeValue)
        }
        catch
        {
            # Assume it is a UTC tick
            $parsingType = 'DateTimeOffset.UtcTicks'
            $date = New-Object -Type 'System.DateTimeOffset' -ArgumentList @($timeValue, [System.TimeSpan]::Zero)
        }
    }
    else
    {
        # If it starts with 0x, try parsing it as a number again
        if ($timeString.StartsWith('0x', [System.StringComparison]::OrdinalIgnoreCase))
        {
            if ([System.UInt64]::TryParse($timeString.Substring(2), [System.Globalization.NumberStyles]::HexNumber, $null, [ref] $timeValue))
            {
                $parsingType = 'FILETIME'
                $date = [System.DateTimeOffset]::FromFileTime($timeValue)
            }
            else
            {
                throw "Cannot parse $timeString as a hexadecimal number."
            }
        }
        elseif ($timeString.EndsWith('_iOS', [System.StringComparison]::Ordinal))
        {
            # 20230213_194534000_iOS
            # yyyyMMdd_HHmmsszzz_iOS
            $parsingType = 'iOS file name'

            [System.Globalization.DateTimeStyles] $styles = [System.Globalization.DateTimeStyles]::AllowWhiteSpaces
            [System.DateTime] $timeValue = [System.DateTime]::Now
            if ([System.DateTime]::TryParseExact($timeString.Substring(0, 18), "yyyyMMdd_HHmmssFFF", [System.Globalization.CultureInfo]::InvariantCulture, $styles, [ref] $timeValue))
            {
                Write-Debug "iOS TryParseExact: $($timeValue)"
                $date = New-Object -Type 'System.DateTimeOffset' -ArgumentList @($timeValue, [System.TimeSpan]::Zero)
                Write-Debug "iOS TryParseExact as DateTimeOffset: $($date)"
            }
            else {
                throw "Cannot parse $timeString as an iOS file name."
            }
        }
        else
        {
            $parsingType = 'DateTimeOffset'
            $date = [System.DateTimeOffset]::Parse($timeString)
        }
    }

    Write-Host 'Parsed as............:' $date 'as' $parsingType
}

$fileTimeString = '{0:X}' -f $date.ToFileTime()
Write-Host 'Local time...........:' $date.ToLocalTime()
Write-Host 'UTC..................:' $date.ToUniversalTime()
Write-Host 'Unix Time (seconds)..:' $date.ToUnixTimeSeconds()
Write-Host "Windows File Time....: 0x$fileTimeString"
Write-Host 'ISO 8601.............:' $date.ToString('yyyy-MM-ddTHH:mm:ss.fffffffzzz', [CultureInfo]::InvariantCulture) '  see https://en.wikipedia.org/wiki/ISO_8601'

Write-Host
Write-Host 'Time zones on a world map is available at https://www.timeanddate.com/time/map/, and as a table at https://everytimezone.com/.'
