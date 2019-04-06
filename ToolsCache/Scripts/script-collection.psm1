# -----------------------------------------------------------------------
# <copyright file="script-collection.psm1" company="Stephan Adler">
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

# -----------------------------------------------------------------------
# STRING HELPER FUNCTIONS
# -----------------------------------------------------------------------

<#
.SYNOPSIS
    Remove new lines from the input data.
#>
function Remove-Newline
{
    param([string] $data)

    return ($data.Replace([System.Environment]::NewLine, ' '))
}


# -----------------------------------------------------------------------
# PATH HELPER FUNCTIONS
# -----------------------------------------------------------------------

<#
.SYNOPSIS
    The home path of the developer. Usually this is the user profile of 
    current user.
#>
function Get-DeveloperHomePath
{
    if (-not ([System.String]::IsNullOrWhitespace($env:_NTDEVELOPER)))
    {
        if ([System.IO.Directory]::Exists($env:_NTDEVELOPER))
        {
            return ($env:_NTDEVELOPER)
        }
    }

    return ($env:USERPROFILE)
}

<#
.SYNOPSIS
    The source code root path of the current system.
#>
function Get-SourceCodeRootPath
{
    if (-not ([System.String]::IsNullOrWhitespace($env:SOURCES_ROOT)))
    {
        return ($env:SOURCES_ROOT)
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

<#
.SYNOPSIS
    The root path of the current working copy/enlistment.
#>
function Get-WorkingCopyRootPath
{
    if (-not ([System.String]::IsNullOrWhitespace($env:INETROOT)))
    {
        # CoreXT. Even though the rarest, checking the value of an environment
        # variable is still the fastest.
        return ($env:INETROOT)
    }

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
            return ($rootDir)
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
                    return ($path)
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

    return ''
}

<#
.SYNOPSIS
    Tests if a file exists and returns the path or $null.
#>
function Test-FileExists
{
    param([string] $file)

    if ([System.String]::IsNullOrEmpty($file) -eq $true)
    {
        return $null
    }

    if ([System.IO.File]::Exists($file) -eq $false)
    {
        return $null
    }

    return $file
}

Export-ModuleMember -Function Remove-Newline

Export-ModuleMember -Function Get-DeveloperHomePath
Export-ModuleMember -Function Get-SourceCodeRootPath
Export-ModuleMember -Function Get-WorkingCopyRootPath
Export-ModuleMember -Function Test-FileExists
