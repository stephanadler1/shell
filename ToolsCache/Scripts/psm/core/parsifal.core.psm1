# Copyright (c) Stephan Adler.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $global:DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}


# A list of tools that always use legacy argument passing, irrespective of the 
# arguments themselves.
$legacyArgumentPassingToolList = @(
    #'azcopy', 'azcopy.exe'
    #, 'git', 'git.exe'
)


function Invoke-Tool
{
    <#
    .SYNOPSIS
    Invokes an external tool and applies certain mitigations to ensure command lines
    are passed to the invoked tool and not intercepted and interpreted by PowerShell.
    #>

    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]] $ArgumentList,

        [Parameter(Mandatory = $false)]
        [switch] $ForceLegacy = $false
    )

    $private:currentBehavior = $null
    if (($PSVersionTable.PSVersion -ge '7.3') -and ($IsWindows -eq $true))
    {
        # See PSNativeCommandArgumentPassing description and its ramifications in 
        # https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#psnativecommandargumentpassing
        if ($ForceLegacy)
        {
            $currentBehavior = $PSNativeCommandArgumentPassing
        }
        elseif ($legacyArgumentPassingToolList -icontains $FilePath)
        {
            $currentBehavior = $PSNativeCommandArgumentPassing
        }
        else 
        {
            $ArgumentList | ForEach-Object {
                if (($_ -match '(%| |&|\?)') -and -not $_.StartsWith('"'))
                {
                    $currentBehavior = $PSNativeCommandArgumentPassing
                }
            }
        }
        
    }

    try
    {
        if ($null -ne $currentBehavior)
        {
            Write-Debug "Tool invocation (with legacy argument passing): $FilePath $ArgumentList"
            $script:PSNativeCommandArgumentPassing = 'Legacy'
        }
        else
        {
            Write-Debug "Tool invocation: $FilePath $ArgumentList"
        }

        & $FilePath $ArgumentList
    }
    finally {
        if ($null -ne $currentBehavior)
        {
            $script:PSNativeCommandArgumentPassing = $currentBehavior
        }
    }

    Write-Debug "Tool invocation -> Exit code: $LASTEXITCODE"
}


function Test-ToolExists
{
    <#
    .SYNOPSIS
    Checks if the $toolName is available on the system, either at the
    provided location or somewhere on $env:PATH.
    #>

    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $toolName)

    if ([IO.File]::Exists($toolName) -eq $true)
    {
        # In case this is a full path to the tool
        return
    }

    try {
        Get-Command $toolName | Out-Null
    }
    catch {
        Write-Error -Message "Tool '$toolName' is not available on the system."
    }
}


function Test-ForThreats
{
    <#
    .SYNOPSIS
    Scans the folder $path for viruses using the default scanners on a Windows system.
    #>

    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $path)

    if ([System.IO.Directory]::Exists($path) -eq $false)
    {
        return
    }

    [string] $private:avtool = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    if ([System.IO.File]::Exists($avtool) -eq $false)
    {
        Write-Host "AV Tool not found at '$avtool'."

        $avtool = Join-Path -Path $env:ProgramFiles -ChildPath 'Microsoft Security Client\Antimalware\MpCmdRun.exe'
        if ([System.IO.File]::Exists($avtool) -eq $false)
        {
            Write-Host "AV Tool not found at '$avtool'."
            return
        }
    }

    Write-Host "Scanning the '$path' to ensure no known threats..."
    $private:scanArgs = @(
        '-scan',
        '-disableremediation',
        '-scantype', '3',
        '-timeout', '1',
        '-file', "$path")
    Invoke-Tool $avtool $scanArgs
    if ($LASTEXITCODE -eq 2)
    {
        throw 'Virus detected.'
    }
}


function Remove-FileSecure
{
    <#
    .SYNOPSIS
    Remove a file securely from the system using sysinternals sdelete.exe
    #>

    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $file,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $sDeleteToolPath = 'sdelete'

    )

    if ([System.IO.File]::Exists($file) -eq $false)
    {
        # Nothing to delete.
        return
    }

    Test-ToolExists $sDeleteToolPath

    $private:sDeleteDefaultArgs = @(
        '-r',
        '-nobanner',
        '-accepteula')

    $private:sDeleteArgs = $sDeleteDefaultArgs + ($file)
    Invoke-Tool $sDeleteToolPath $sDeleteArgs
}
