# Copyright (c) Stephan Adler.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}


function Test-AzureCliVersion
{
    <#
    .SYNOPSIS
    Ensures that the minimum Azure CLI version is installed on the system.
    #>

    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $azCliToolPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $azMinVersion
    )

    Test-ToolExists $azCliToolPath

    # The new auto-upgrade features is a real problem for a simple version check,
    # since as soon as a new version is available it will block the execution
    # to ask if you want to update.
    # The first step therefore is to disalbe auto-upgrade.
    [bool] $private:azCliAutoUpgradeEnabled = $false
    $private:azConfig = & $azCliToolPath @('config', 'get', 'auto-upgrade.enable', '-o', 'json') | ConvertFrom-Json
    Write-Debug $azConfig
    $azCliAutoUpgradeEnabled = ($azConfig.value -ieq 'yes')

    try
    {
        if ($true -eq $azCliAutoUpgradeEnabled)
        {
            & $azCliToolPath @('config', 'set', 'auto-upgrade.enable=no') | Out-Null
        }

        $private:azVersion = & $azCliToolPath @('version', '-o', 'json') | ConvertFrom-Json
        if (([System.Version] $azMinVersion).CompareTo([System.Version] $azVersion.'azure-cli') -gt 0)
        {
            Write-Host $azVersion
            throw "The script requires Azure CLI version $azMinVersion or higher. Run az upgrade."
        }
    }
    finally
    {
        if ($true -eq $azCliAutoUpgradeEnabled)
        {
            & $azCliToolPath @('config', 'set', 'auto-upgrade.enable=yes') | Out-Null
        }
    }
}


function Request-AzureAccess
{
    <#
    .SYNOPSIS
    Ensures that the user has access to Azure resources. If the user is not yet
    logged in, a login request will be issued.
    #>

    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $azCliToolPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $tenantId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $subscriptionId
    )

    Test-ToolExists $azCliToolPath

    # Ensure an Azure authentication token is cached. List all subscriptions to
    # enable the validation below.
    $private:azCliArgs = @(
        'account',
        'list',
        '-o', 'json')
    $private:azLoginData = & $azCliToolPath $azCliArgs | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0)
    {
        $azCliArgs = @(
            'login',
            '--tentant', $tenantId,
            '-o', 'json')
        $azLoginData = & $azCliToolPath $azCliArgs | ConvertFrom-Json
        if ($LASTEXITCODE -ne 0)
        {
            throw 'Azure login failed.'
        }
    }

    Write-Debug ($azLoginData | ConvertTo-Json)

    # Ensure that the requested subscription is enabled on the account.
    if ($null -eq ($azLoginData | Where-Object { $_.id -ieq $subscriptionId}))
    {
        throw "The subscription id $subscriptionId was not found in tenant $tenantId."
    }

}


function Test-TerraformCurrent
{
    <#
    .SYNOPSIS
    Ensure no pending updates for Terraform.
    #>

    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $terraformToolPath
    )

    Test-ToolExists $terraformToolPath

    # Ensure the latest stuff is used
    [string] $private:result = & $terraformToolPath @("-version")
    if ($result.IndexOf('is out of date', [System.StringComparison]::OrdinalIgnoreCase) -ge 0)
    {
        Write-Warning "The current version of Terraform is out-of-date and should be updated: '$result'"
    }
}
