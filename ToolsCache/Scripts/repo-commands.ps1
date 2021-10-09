# -----------------------------------------------------------------------
# <copyright file="repo-commands.ps1" company="Stephan Adler">
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
    # Advanced repo command.
    [Parameter(Mandatory = $true)]
    [ValidateSet('repobrowser', 'revisiongraph', 'log')]
    [string] $command,

    # The working directory for the command.
    [Parameter(Mandatory = $true)]
    [ValidateScript({[System.IO.Directory]::Exists($_) -eq $true})]
    [string] $currentDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
}

Import-Module -Name (Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath 'script-collection.psm1') -Scope Local -Force

$script:tortGitPath = [IO.Path]::Combine($env:ProgramFiles, 'TortoiseGit\bin\TortoiseGitProc.exe')
$script:tortSvnPath = [IO.Path]::Combine($env:ProgramFiles, 'TortoiseSVN\bin\TortoiseProc.exe')

$script:toolFound = $false

Write-Debug "Git................: $tortGitPath"
Write-Debug "SVN................: $tortSvnPath"

if ($command -ine 'log')
{
    $script:workingCopyRootPath = Get-WorkingCopyRootPath
    $currentDirectory = $workingCopyRootPath
    Write-Debug "Working Copy Root..: $workingCopyRootPath"
}

try {
    if (Test-Git)
    {
        if ([IO.File]::Exists($tortGitPath) -eq $true)
        {
            # https://tortoisegit.org/docs/tortoisegit/tgit-automation.html
            Start-Process -FilePath $tortGitPath -ArgumentList @("/command:$command", "/path:$currentDirectory") | Out-Null
            $toolFound = $true
        }
        else
        {
            switch ($command)
            {
                'log' { & gitk.exe @($currentDirectory); break }
                'repobrowser' { & gitk.exe @('--all', $currentDirectory); break }
            }
        }
    }

    if (Test-Subversion -and ([IO.File]::Exists($tortSvnPath) -eq $true))
    {
        # https://tortoisesvn.net/docs/nightly/TortoiseSVN_en/tsvn-automation.html
        Start-Process -FilePath $tortSvnPath -ArgumentList @("/command:$command", "/path:$currentDirectory") | Out-Null
        $toolFound = $true
    }
}
catch
{
}

if (-not $toolFound)
{
    $script:message = 'Advanced repository commands rely on additional source control tools to be ' + `
        'available on the system depending on the type of repository being used. ' + `
        'In case of Git or Subversion these are TortoiseGit and TortoiseSVN. ' + `
        'See ''dhelp repo-commands'' for more information.' + [Environment]::NewLine + `
        'Alternatively you can use commands like ''gitk'' or ''git gui'' that are available with the basic source control tools.'
    Write-Warning $message
}
