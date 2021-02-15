# -----------------------------------------------------------------------
# <copyright file="decode-jwt.ps1" company="Stephan Adler">
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
    # JWT token
    [Parameter(Mandatory = $false)]
    [string] $jwtToken
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
}


#Add-Type -Path 'D:\Users\Stephan\BTSync\Shared Tools\ToolsCache\Scripts\refs\System.IdentityModel.Tokens.Jwt.dll'
#[System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler] $handler = New-Object -Type 'System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler'
#if ($handler.CanReadToken($jwtToken))
#{
#    [System.IdentityModel.Tokens.SecurityToken] $token = $handler.ReadJwtToken($jwtToken)
#    $token | ft
#}

if ([System.String]::IsNullOrWhitespace($jwtToken))
{
    $jwtToken = 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJJU1MiLCJzY29wZSI6Imh0dHBzOi8vbGFyaW0uZG5zY2UuZG91YW5lL2NpZWxzZXJ2aWNlL3dzIiwiYXVkIjoiaHR0cHM6Ly9kb3VhbmUuZmluYW5jZXMuZ291di5mci9vYXV0aDIvdjEiLCJpYXQiOiJcL0RhdGUoMTQ2ODM2MjU5Mzc4NClcLyJ9'
    $jwtToken = 'eyJhbGciOiJSUzI1NiIsIng1dCI6IjdkRC1nZWNOZ1gxWmY3R0xrT3ZwT0IyZGNWQSIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2NvbnRvc28uY29tIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvZTQ4MTc0N2YtNWRhNy00NTM4LWNiYmUtNjdlNTdmN2QyMTRlLyIsIm5iZiI6MTM5MTIxMDg1MCwiZXhwIjoxMzkxMjE0NDUwLCJzdWIiOiIyMTc0OWRhYWUyYTkxMTM3YzI1OTE5MTYyMmZhMSJ9.C4Ny4LeVjEEEybcA1SVaFYFS6nH-Ezae_RrTXUYInjXGt-vBOkAa2ryb-kpOlzU_R4Ydce9tKDNp1qZTomXgHjl-cKybAz0Ut90-dlWgXGvJYFkWRXJ4J0JyS893EDwTEHYaAZH_lCBvoYPhXexD2yt1b-73xSP6oxVlc_sMvz3DY__1Y_OyvbYrThHnHglxvjh88x_lX7RN-Bq82ztumxy97rTWaa_1WJgYuy7h7okD24FtsD9PPLYAply0ygl31ReI0FZOdX12Hl4THJm4uI_4_bPXL6YR2oZhYWp-4POWIPHzG9c_GL8asBjoDY9F5q1ykQiotUBESoMML7_N1g'
}

Write-Host
Write-Host 'DECODING JSON WEB TOKENS' -ForegroundColor yellow
Write-Host 'Documentation and structure can be found at https://tools.ietf.org/html/rfc7519.' -ForegroundColor yellow
Write-Host

$tokenParts = $jwtToken.Split(@('.'), 3, [System.StringSplitOptions]::RemoveEmptyEntries)

$parts = @('Header', 'Payload', 'Signature')

for($i = 0; $i -lt $tokenParts.Count; $i++)
{
    "{0,-10}: " -f $parts[$i] | Write-Host -NoNewline -ForegroundColor green

    if ($i -eq 2)
    {
        Write-Host $tokenParts[$i]
    }
    else
    {
        $text = $null
        $padding = ''
        while($null -eq $text)
        {
            try
            {
                $text = $([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($tokenParts[$i] + $padding)))
            }
            catch [System.FormatException]
            {
                $padding += '='

                if ($padding.Length -gt 2)
                {
                    # Break if ==. No more padding necessary, return original token instead.
                    $text = $tokenParts[$i]
                }
            }
        }

        Write-Host $text
    }
}

