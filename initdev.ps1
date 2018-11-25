# -----------------------------------------------------------------------
# <copyright file="initdev.ps1" company="Stephan Adler">
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


Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Set the window title
$host.ui.RawUI.WindowTitle = "Developer Shell (PowerShell $($PSVersionTable.PSVersion))"

$env:_WORKINGDIR = (Get-Item -Path '.')

Import-Module -Name "$env:TOOLS\Scripts\developer-console.psm1"

Write-Host 'GLOBAl TOOLS'
Write-Host '------------'
Get-ChildItem -Path $env:TOOLS -File | ForEach-Object { Write-Host "$_   " -NoNewline }
Write-Host

if ($env:TOOLS_GIT -ne '')
{
    Write-Host
    Write-Host 'GLOBAL GIT ALIASES'
    Write-Host '------------------'
    & git config --global --get-regexp alias.
}


Write-Host
