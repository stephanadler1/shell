# -----------------------------------------------------------------------
# <copyright file="configure-os.ps1" company="Stephan Adler">
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

<#
.SYNOPSIS
This script configures the host operating system usable for me (Stephan Adler).

.DESCRIPTION
It makes the following changes:

* Disables hibernate, use use sleep instead.
* Disables connected standby, not helpful on desktops or notebooks.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $global:DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}


# If not already running in an elevated command prompt, elevate it now.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
{
    Write-Host 'Elevating to administrative privileges is required to re-configure the operating system...'
    $arg = "-nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file `"$($script:MyInvocation.MyCommand.Path)`""
    Start-Process -FilePath (Get-Process -Id $PID).Path -Verb Runas -ArgumentList $arg -wait
    exit
}

$script:rootPath = Split-Path $script:MyInvocation.MyCommand.Path -Parent
Import-Module "$rootPath\install.psm1" -Scope Local -Force

$script:rebootRequired = $false

# The various power plans and there schema GUIDs are documented in
# https://winbuzzer.com/2020/11/26/windows-10-power-plans-missing-or-changed-heres-how-to-restore-or-reset-them-xcxwbt
#
# Power saver power plan: a1841308-3541-4fab-bc81-f71556f20b4a
# Balanced power plan: 381b4222-f694-41f0-9685-ff5bb260df2e
# High Performance power plan: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
# Ultimate Performance power plan: e9a42b02-d5df-448d-aa00-03f14749eb61
$script:planHighPerfGuid = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
$script:planHighPerfName = 'High performance'
$script:powerCfgTool = 'powercfg.exe'

# Get current installed plans
$script:planHighPerfInstalled = $false
[array] $script:plans = Get-WmiObject -Class 'Win32_PowerPlan' -Namespace 'root\cimv2\power'
$plans | ForEach-Object {

    $_ | ConvertTo-Json -Depth 1 | Write-Debug

    if ($_.ElementName -ieq $planHighPerfName)
    {
        $planHighPerfInstalled = $true
        Write-Debug "$planHighPerfName is installed."
    }

    if ($_.ElementName -ieq 'Ultimate Performance')
    {
        $planHighPerfInstalled = $true
        Write-Debug "Ultimate Performance is installed."
    }
}

if ($planHighPerfInstalled -eq $false)
{
    Write-Host "$planHighPerfName is missing. Creating it..."

    Write-Debug 'Create the plan from it''s schema'
    $private:powerCfgResult = & $powerCfgTool @('/duplicatescheme', $planHighPerfGuid)
    if ($LASTEXITCODE -ne 0)
    {
        Write-Warning "Installing power plan schema $planHighPerfName failed with exit code $LASTEXITCODE."
    }
    else
    {
        # Find the GUID of the newly installed plan in the following output string
        # Power Scheme GUID: 4803388f-bebe-4ebd-9e70-c55002d3bac4  (High performance)
        [System.Guid] $private:installedPlanGuid = `
            [System.Guid]::ParseExact($powerCfgResult.Substring(19,36), 'D')

        # Check if the plan is actually visible. Sometimes it will not be despite being installed
        [array] $script:newlyInstalledPlans = $null
        try {
            $newlyInstalledPlans = Get-WmiObject `
            -Class 'Win32_PowerPlan' `
            -Namespace 'root\cimv2\power' `
            -Filter "InstanceID=Microsoft:PowerPlan\\$($installedPlanGuid.ToString('B'))"
            -ErrorAction SilentlyContinue
        }
        catch {
            Write-Debug "Could not query Wmi with Get-WmiObject. $_"
            $newlyInstalledPlans = $null
        }
        if ($null -eq $newlyInstalledPlans -or $newlyInstalledPlans.Length -le 0)
            {
            # One of those systems that require the new plan to be activated
            # in order to be registered as installed.
            Write-Debug "New plan with GUID '$installedPlanGuid' wasn't found. Set it to 'active' to make it permanent."
            & $powerCfgTool @('/setactive', $installedPlanGuid.ToString('D'))
        }
    }
}
else
{
    Write-Host 'Power plans are current. Nothing to do.'
}

if (-not (IsSystemDriveOnSsd))
{
    Write-Host 'Disable hibernate, since OS drive is an HDD...'
    & $powerCfgTool @('/Hibernate', 'Off')
}
else
{
    # Only enable Hibernate if Modern Sleep isn't supported
    [string] $powerCfgOutput = & powercfg.exe /availablesleepstates
    if (-not $powerCfgOutput.StartsWith('The following sleep states are available on this system:     Standby (S0 Low Power Idle) Network Connected', [System.StringComparison]::OrdinalIgnoreCase))
    {
        Write-Host 'Enable hibernate, since OS drive is an SSD...'
        & $powerCfgTool @('/Hibernate', 'On')
    }

    # Only enable Hibernate if machine isn't OEM...
    [string] $manufacturer = (Get-WmiObject win32_bios).Manufacturer
    if (-not $manufacturer.StartsWith('OEM', [System.StringComparison]::OrdinalIgnoreCase))
    {
        #Write-Host 'Enable hibernate, since OS drive is an SSD...'
        #& $powerCfgTool @('/Hibernate', 'On')
    }
}

# Write-Host 'Disabe firewall rules...'
# Get-NetFirewallRule
# Get-NetFirewallRule | ? {  $_.Direction -eq 'Inbound' } | % { $_ } | fl

Write-Host 'Validating connected standby...'
# http://windowsitpro.com/windows-client/disabling-windows-connected-standby
$script:connectedStandbyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
$script:connectedStandbyValue = Get-ItemProperty -path $connectedStandbyPath -name 'CsEnabled' -ErrorAction 'SilentlyContinue'
if ($null -ne $connectedStandbyValue -and $connectedStandbyValue.CsEnabled -ne 0)
{
    Write-Host 'Would like to disable connected standby... not doing it though!'
    #Write-Host 'Disable connected standby...'
    #Write-Host $connectedStandbyValue.CsEnabled
    #Set-ItemProperty -path $connectedStandbyPath -Name 'CsEnabled' -Value 0
    #$rebootRequired = $true
}

$script:registeredOwnerPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
# $script:registerdOwnerValue = Get-ItemProperty -path $registeredOwnerPath -name 'RegisteredOwner'
#Set-ItemProperty -path $registeredOwnerPath -Name 'RegisteredOwner' -Value 'Stephan Adler'

if (Get-Command 'Add-MpPreference' -errorAction SilentlyContinue)
{
    $defenderProcessExclusions = @(
        'devenv.exe', # Visual Studio
        'msbuild.exe')

    Write-Host 'Configure Windows Defender...'
    Add-MpPreference -ExclusionProcess $defenderProcessExclusions
}


Write-Host 'Block execution of certain applications...'
$rk = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options', $true)
foreach($ifeo in @('MmReminderService.exe', 'Tobii.Service.exe'))
{
    $subKey = $rk.CreateSubKey($ifeo, $true)
    $subKey.SetValue('Debugger', "$([System.Environment]::GetEnvironmentVariable('COMSPEC')) /d /c `"echo Usage of this tool is blocked: '$ifeo'. [Fingerprint b808757193bc437f97a6593d4ec3106d] & exit 1`"")
    Write-Host "Blocked execution of '$ifeo'."
}

foreach($ifeo in @())
{
    $subKey = $rk.DeleteSubKey($ifeo, $false)
    Write-Host "Unblocked execution of '$ifeo'."
}

Write-Host 'Set unused services to disabled startup...'
foreach($service in @())
{
    # Don't add the following services, since their client applications will
    # cause an elevation prompt to restore them
    # - FoxitReaderService - IFEO FoxitConnectedPDFService.exe instead. Doesn't work either.
    Set-Service -Name $service -StartupType Manual -ErrorAction SilentlyContinue
    Stop-Service -Name $service -ErrorAction SilentlyContinue
    Write-Host "Disabled startup '$service'."
}

Write-Host 'Stop unused services...'
foreach($service in @())
{
    Stop-Service -Name $service -ErrorAction SilentlyContinue
}

$script:updateTypes = @{}
$updateTypes['.md'] = 'txtfile'
$updateTypes['.js'] = 'JSFile'

$rk = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey($null, $true)
$updateTypes.Keys | ForEach-Object {
    Write-Host "Updating registration of '$_' to be '$($updateTypes[$_])'."

    $private:fileExtension = $_
    switch ($updateTypes[$fileExtension])
    {
        'htmlfile' {
            $subKey = $rk.CreateSubKey($fileExtension, $true)
            $subKey.SetValue($null, 'htmlfile')
            $subKey.SetValue('Content Type', 'text/html')
            $subKey.SetValue('PerceivedType', 'html')
        }

        'txtfile' {
            $subKey = $rk.CreateSubKey($fileExtension, $true)
            $subKey.SetValue($null, 'txtfile')
            $subKey.SetValue('Content Type', 'text/plain')
            $subKey.SetValue('PerceivedType', 'text')
        }

        'JSFile' {
            $subKey = $rk.CreateSubKey($fileExtension, $true)
            $subKey.SetValue($null, 'JSFile')
            $subKey.SetValue('Content Type', 'text/javascript')
            $subKey.SetValue('PerceivedType', 'text')
        }

        default {
            Write-Warning "No definition for '$_' found."
        }
    }
}
$rk.Close()
$rk.Dispose()

# Disable RDP over UDP
# https://superuser.com/questions/1481191/remote-desktop-intermittently-freezing


if ($env:POWERSHELL_TELEMETRY_OPTOUT -ne '1')
{
    # Disable telemetry gathering
    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_telemetry?view=powershell-7.4
    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '1', [System.EnvironmentVariableTarget]::Machine)

    $rebootRequired = $true
}

if ($env:DOTNET_CLI_TELEMETRY_OPTOUT -ne '1')
{
    # Disable telemetry gathering
    # https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-environment-variables#net-sdk-and-cli-environment-variables
    [System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', '1', [System.EnvironmentVariableTarget]::Machine)

    $rebootRequired = $true
}


Write-Host 'Done.'

if ($rebootRequired -eq $true)
{
    Write-Host 'Reboot required.'
}

Read-Host
