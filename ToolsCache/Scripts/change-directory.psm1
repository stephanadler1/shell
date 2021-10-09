# -----------------------------------------------------------------------
# <copyright file="change-directory.psm1" company="Stephan Adler">
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
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
}

if ($host.Version.Major -lt 5)
{
    throw "This module requires at least PowerShell version 5."
}

class GitRepository
{
    [string] $comment
    [ValidateNotNullOrEmpty()][string[]] $repository_uris
    $shortcuts
}

class SourceDepotRepository
{
    [string] $comment
    [ValidateNotNullOrEmpty()][string] $repository_port
    $shortcuts
}

class DirectoryShortcutSettings
{
    [GitRepository[]] $git_repositories
    [SourceDepotRepository[]] $sourcedepot_repositories
}

function Get-ShortcutsPath()
{
    param(
        [string] $relativePath,
        [string] $subFolder
    )

    # Start with a file in the repository root folder, aka. local.
    [string] $settingsFileName = 'directory.shortcuts.json'
    [bool] $isLocalSettingsFile = $true
    [string] $workingCopyRoot = Get-WorkingCopyRootPath
    Write-Debug "Working copy root is at '$workingCopyRoot'."

    [string] $settingsFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($workingCopyRoot, $settingsFileName))
    if ([System.IO.File]::Exists($settingsFile) -eq $false)
    {
        # Next up, check if there is a file in the folder containing all working copies.
        $isLocalSettingsFile = $false
        $settingsFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($(Get-SourceCodeRootPath), $settingsFileName))
        if ([System.IO.File]::Exists($settingsFile) -eq $false)
        {
            # Finally, use a file that can be distributed with the developer tools.
            $settingsFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($(Split-Path -Parent $PSCommandPath), '..', $settingsFileName))
        }
    }

    Write-Debug "Assuming settings file is at '$settingsFile'."

    if ([System.IO.File]::Exists($settingsFile) -eq $true)
    {
        $target = $relativePath
        $relativePath = ''

        # Load and parse the settings file
        [DirectoryShortcutSettings] $settings = Get-Content -Path $settingsFile | ConvertFrom-Json

        if ($null -ne $settings)
        {
            if (Test-Git -and ($null -ne $settings.git_repositories))
            {
                $repoUri = & git remote get-url origin 2>&1
                if ($LASTEXITCODE -eq 0)
                {
                    Write-Host "Current repository is '$repoUri'."

                    # Do not change to foreach, since it's semantics are different!
                    for($i = 0; $i -lt $settings.git_repositories.Count; $i++)
                    {
                        $r = $settings.git_repositories[$i]
                        if (($r.repository_uris -contains $repoUri) -or ($isLocalSettingsFile -and $r.repository_uris -contains '.'))
                        {
                            Write-Debug "Found repository '$repoUri' in settings file."

                            if (-not [System.String]::IsNullOrWhiteSpace($target) -eq $true)
                            {
                                try
                                {
                                    $env:INETROOT = ''
                                    Write-Debug "Navigate to '$($r.shortcuts.$target)'."
                                    $path = [System.IO.Path]::Combine($(Get-WorkingCopyRootPath), $r.shortcuts.$target, $subFolder)
                                    return ($path)
                                }
                                catch
                                {
                                }
                            }
                            else
                            {
                                Write-Host 'The following change-directory shortcuts are defined for this repository:'
                                $r.shortcuts | Format-List | Out-String | ForEach-Object { Write-Host $_ }
                            }

                            break
                        }
                    }
                }
            }

            elseif (Test-SourceDepot -and ($null -ne $settings.sourcedepot_repositories))
            {
                $repoUri = ($env:SDPORT).TrimEnd()
                Write-Host "Current repository is '$repoUri'."

                # Do not change to foreach, since it's semantics are different!
                for($i = 0; $i -lt $settings.sourcedepot_repositories.Count; $i++)
                {
                    $r = $settings.sourcedepot_repositories[$i]
                    if ([String]::Equals($r.repository_port, $repoUri, [System.StringComparison]::OrdinalIgnoreCase))
                    {
                        Write-Debug "Found repository '$repoUri' in settings file."

                        if (-not [System.String]::IsNullOrWhiteSpace($target) -eq $true)
                        {
                            try
                            {
                                Write-Debug "Navigate to '$($r.shortcuts.$target)'."
                                $path = [System.IO.Path]::Combine($(Get-WorkingCopyRootPath), $r.shortcuts.$target, $subFolder)
                                return ($path)
                            }
                            catch
                            {
                            }
                        }
                        else
                        {
                            Write-Host 'The following change-directory shortcuts are defined for this repository:'
                            $r.shortcuts | Format-List | Out-String | ForEach-Object { Write-Host $_ }
                        }

                        break
                    }
                }
            }
        }
    }

    return $null
}
