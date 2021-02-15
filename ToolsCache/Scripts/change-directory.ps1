# -----------------------------------------------------------------------
# <copyright file="change-directory.ps1" company="Stephan Adler">
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
    [ValidateSet('self', 'root', 'dev', 'shortcut')]
    [string] $option,

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

    Import-Module -Name (Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath 'script-collection.psm1')

    if ($host.Version.Major -ge 5)
    {
        Import-Module -Name (Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath 'change-directory.psm1') -Scope Local -Force
    }
}

process {
    $script:changeTo = ''
    $script:changeToSub = ''

    if ($option -eq 'self') { $changeTo = Get-DeveloperHomePath }
    if ($option -eq 'root') { $changeTo = Get-WorkingCopyRootPath }
    if ($option -eq 'dev')  { $changeTo = Get-SourceCodeRootPath }
    if (($option -eq 'shortcut') -and ($host.Version.Major -ge 5))
    {
        $changeTo = Get-ShortcutsPath($relativePath)
    }

    #Write-Debug "*** ChangeTo=$changeTo"

    $relativePath = $relativePath.TrimEnd('\')
    #Write-Host "*** RelativePath=$relativePath"

    if (-not ([System.String]::IsNullOrWhitespace($relativePath)))
    {
        $changeToSub = [System.IO.Path]::Combine($changeTo, $relativePath)
    }

    #Write-Host "*** ChangeToSub=$changeToSub"

    $script:switchTo = ''
    if ([System.IO.Directory]::Exists($changeToSub))
    {
        $switchTo = $changeToSub
    }
    elseif ([System.IO.Directory]::Exists($changeTo))
    {
        $switchTo = $changeTo
    }

    #Write-Host "*** SwitchTo=$switchTo"
    #Write-Host "*** GetCurrentDirectory=$([System.IO.Directory]::GetCurrentDirectory())"
    if (-not ([System.IO.Directory]::GetCurrentDirectory().Equals($switchTo, [System.StringComparison]::OrdinalIgnoreCase) -eq $true))
    {
        Set-Location -Path $switchTo | Out-Null
        Write-Output $switchTo
        return
    }

    Write-Output ''
}
