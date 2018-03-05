# -----------------------------------------------------------------------
# <copyright file="developer-console.psm1" company="Stephan Adler">
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


function global:prompt
{
    Write-Host "$(Get-Date -Format 'HH:mm:ss') " -NoNewline -ForegroundColor DarkGreen
    Write-Host "$(Get-Item -Path '.')" -ForegroundColor Green
    return 'PS> '
}

function script:Push-LocationUp1 { Push-Location '..' }
function script:Push-LocationUp2 { Push-Location '..\..' }
function script:Push-LocationUp3 { Push-Location '..\..\..' }
function script:Push-LocationUp { Push-Location '..\..\..\..' }

function script:Push-LocationDev { Push-Location 'd:\dev' }


Set-Alias -Name 'up' Push-LocationUp1
Set-Alias -Name 'up2' Push-LocationUp2
Set-Alias -Name '..' Push-LocationUp2
Set-Alias -Name 'up3' Push-LocationUp3
Set-Alias -Name '...' Push-LocationUp3
Set-Alias -Name 'up4' Push-LocationUp4
Set-Alias -Name '....' Push-LocationUp4
Set-Alias -Name 'bb' Pop-Location
Set-Alias -Name 'dev' Push-LocationDev

