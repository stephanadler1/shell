# -----------------------------------------------------------------------
# <copyright file="open-webpage.ps1" company="Stephan Adler">
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
    [string] $url,

    [Parameter(Mandatory = $false)]
    [string] $relativePath = ''
)

begin {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
    {
        $DebugPreference = 'Continue'
    }
}

process {
    [System.Uri] $script:baseUri = New-Object -TypeName System.Uri -ArgumentList @($url, [System.UriKind]::Absolute)
    [System.Uri] $script:uri = New-Object -TypeName System.Uri -ArgumentList @($baseUri, $relativePath)

    Start-Process $uri
}
