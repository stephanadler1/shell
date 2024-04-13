# Copyright (c) Stephan Adler.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
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
    & $avtool $scanArgs
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
    & $sDeleteToolPath $sDeleteArgs | Write-Debug
}
