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

param(
    [Parameter(Mandatory = $true)]
    [string] $option,

    [Parameter(Mandatory = $false)]
    [string] $relativePath
)

begin {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
}

process {
    $script:changeTo = ''
    $script:changeToSub = ''

    function DeveloperHomePath
    {
        if ($env:_NTDEVELOPER -ne $null)
        {
            if ([System.IO.Directory]::Exists($env:_NTDEVELOPER))
            {
                return $env:_NTDEVELOPER
            }
        }

        return $env:USERPROFILE
    }

    function WorkingCopyRootPath
    {
        try {
            # Git
            & git rev-parse 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0)
            {
                $rootDir = & git rev-parse --show-cdup
                if ([System.String]::IsNullOrWhitespace($rootDir))
                {
                    $rootDir = '.'
                }

                $rootDir = [System.IO.Path]::GetFullPath($rootDir)
                return $rootDir
            }
        }
        catch {
        }

        try {
            # Subversion
            & svn info . 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0)
            {
                $svnOutput = & svn info .
                if ($LASTEXITCODE -eq 0)
                {
                    $regEx = New-Object System.Text.RegularExpressions.Regex('Working Copy Root Path: (.*?)URL:')
                    $match = $regEx.Match($svnOutput)
                    if ($match.Success -and ($match.Groups.Count -ge 1))
                    {
                        $path = $match.Groups[1].Value.TrimEnd(' ')
                        return $path
                    }

                    return ''
                }
            }
        }
        catch {
        }

        try {
            # Mercurial
            & hg root 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0)
            {
                return ''
            }
        }
        catch {
        }

        if (-not ([System.String]::IsNullOrWhitespace($env:INETROOT)))
        {
            # CoreXT
            return ($env:INETROOT)
        }

        return ''
    }

    function SourceCodeRootPath
    {
        if (-not ([System.String]::IsNullOrWhitespace($env:SOURCES_ROOT)))
        {
            return $env:SOURCES_ROOT
        }
        elseif ([System.IO.Directory]::Exists('d:\dev'))
        {
            return 'd:\dev'
        }
        elseif ([System.IO.Directory]::Exists("$env:SYSTEMDRIVE\dev"))
        {
            return "$env:SYSTEMDRIVE\dev"
        }

        return ''
    }


    if ($option -eq 'self') { $changeTo = DeveloperHomePath }
    if ($option -eq 'root') { $changeTo = WorkingCopyRootPath }
    if ($option -eq 'dev')  { $changeTo = SourceCodeRootPath }

    #Write-Host "*** ChangeTo=$changeTo"

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

    if (-not ([System.IO.Directory]::GetCurrentDirectory().Equals($switchTo, [System.StringComparison]::OrdinalIgnoreCase)))
    {
        #Write-Host "*** SwitchTo=$switchTo"
        Set-Location -Path $switchTo | Out-Null
        Write-Output $switchTo
        return
    }

    Write-Output ''
}

