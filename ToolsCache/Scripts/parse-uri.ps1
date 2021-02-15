# -----------------------------------------------------------------------
# <copyright file="parse-uri.ps1" company="Stephan Adler">
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

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [string] $url
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
}

$script:rootPath = Split-Path $script:MyInvocation.MyCommand.Path -Parent
Add-Type -AssemblyName 'System.Web'

$uri = New-Object -TypeName System.Uri -ArgumentList @($url, [UriKind]::Absolute)
Write-Debug $uri

Write-Host

if ($uri.DnsSafeHost.EndsWith('zoom.us', [StringComparison]::OrdinalIgnoreCase))
{
    # $uri.Segments[1] == '/j' for the test meeting
    # parse-uri "https://us04web.zoom.us/j/11111111?pwd=xxxxxxxx"
    Write-Host 'ZOOM Meeting URL detected.'
    $query = [System.Web.HttpUtility]::ParseQueryString($uri.Query)
    Write-Host 'Meeting ID..:' $uri.Segments[2]
    Write-Host 'Password....:' $query['pwd']
}

Write-Host
