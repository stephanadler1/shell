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


# If not already running in an elevated command prompt, elevate it now.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
{
    Write-Host 'Elevating to administrative privileges is required to re-configure the operating system...'
    $arg = "-nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file `"$($script:MyInvocation.MyCommand.Path)`""
    Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList $arg -wait
    exit
}

$script:rootPath = Split-Path $script:MyInvocation.MyCommand.Path -Parent
Import-Module "$rootPath\install.psm1" -Scope Local -Force

$script:rebootRequired = $false

if (-not (IsSystemDriveOnSsd))
{
    Write-Host 'Disable hibernate, since OS drive is an HDD...'
    & 'powercfg.exe' /Hibernate Off
}
else
{
    Write-Host 'Enable hibernate, since OS drive is an SSD...'
    & 'powercfg.exe' /Hibernate On
}
# Write-Host 'Disabe firewall rules...'
# Get-NetFirewallRule
# Get-NetFirewallRule | ? {  $_.Direction -eq 'Inbound' } | % { $_ } | fl

Write-Host 'Disable connected standby...'
# http://windowsitpro.com/windows-client/disabling-windows-connected-standby
$script:connectedStandbyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
$script:connectedStandbyValue = Get-ItemProperty -path $connectedStandbyPath -name 'CsEnabled'
if ($connectedStandbyValue.CsEnabled -ne 0)
{
    Write-Host $connectedStandbyValue.CsEnabled
    Set-ItemProperty -path $connectedStandbyPath -Name 'CsEnabled' -Value 0
    $rebootRequired = $true
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

$rk = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey($null, $true)
foreach($fileExtension in @())
{
    $subKey = $rk.CreateSubKey($fileExtension, $true)
    $subKey.SetValue($null, 'txtfile')
    $subKey.SetValue('Content Type', 'text/plain')
    $subKey.SetValue('PerceivedType', 'text')
}

foreach($fileExtension in @('.md'))
{
    $subKey = $rk.CreateSubKey($fileExtension, $true)
    $subKey.SetValue($null, 'htmlfile')
    $subKey.SetValue('Content Type', 'text/html')
    $subKey.SetValue('PerceivedType', 'html')
}

foreach($fileExtension in @('.js'))
{
    $subKey = $rk.CreateSubKey($fileExtension, $true)
    $subKey.SetValue($null, 'JSFile')
    $subKey.SetValue('ContentType', 'application/javascript')
    $subKey.SetValue('PerceivedType', 'text')
}


Write-Host 'Done.'

if ($rebootRequired -eq $true)
{
    Write-Host 'Reboot required.'
    Read-Host
}

