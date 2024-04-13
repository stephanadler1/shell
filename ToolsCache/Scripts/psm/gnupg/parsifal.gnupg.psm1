# Copyright (c) Stephan Adler.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}


function Unprotect-GnuPgFile
{
    <#
    .SYNOPSIS
    Decrypt the current file.
    #>

    [OutputType([bool])]

    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $file,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $encryptedFile,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $gnuPgToolPath = 'gpg'
    )

    Test-ToolExists $gnuPgToolPath

    if ([System.IO.File]::Exists($encryptedFile) -eq $true)
    {
        Write-Host
        Write-Host "Decrypting the file '$file'..."

        $private:gpgArgs = @(
            '--decrypt',
            '--output', $file,
            '--yes',
            $encryptedFile)

        & $gnuPgToolPath $gpgArgs | Write-Debug
        if ($LASTEXITCODE -ne 0)
        {
            Write-Error "Decrypting the file from '$encryptedFile'. See the errors above."
        }

        return $true
    }

    return $false
}


function Protect-GnuPgFile
{
    [OutputType([bool])]

    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $file,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $encryptedFile,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Array] $recipients,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $gnuPgToolPath = 'gpg'
    )

    Test-ToolExists $gnuPgToolPath

    if ([System.IO.File]::Exists($file) -eq $true)
    {
        Write-Host
        Write-Host "Encrypting the file '$file' ..."

        $private:gpgArgs = @(
            '--encrypt',
            '--output', $encryptedFile,
            '--yes')

        $recipients | Where-Object { $gpgArgs += @('--recipient', """$_""") }

        $gpgArgs += @($file)

        Write-Debug "GPG arguments: $gpgArgs"

        & $gnuPgToolPath $gpgArgs | Write-Debug
        if ($LASTEXITCODE -ne 0)
        {
            Write-Error "Encrypting the state file from '$encryptedFile'. See the errors above."
        }

        return $true
    }

    return $false
}
