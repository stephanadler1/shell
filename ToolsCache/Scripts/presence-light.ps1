# -----------------------------------------------------------------------
# <copyright file="presence-light.ps1" company="Stephan Adler">
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
Sets the status of a connected Embrava Blynclight or PLENOM Kuando Busylight device.

.DESCRIPTION
Provides rudimentary control over an attached presence status light device. The following states (colors) are supported:

 * blue
 * cyan
 * green
 * magenta
 * orange
 * red
 * white
 * yellow
 * off - will turn the light off

In addition the following mappings are available (see https://www.plenom.com/wp-content/uploads/2018/11/Busylight_Poster_A4_Skype_adv-1.pdf)

 * available - green
 * busy - red
 * dnd - magenta
 * away - yellow
 * incoming - blue
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [string] $status,

    [Parameter(Mandatory = $false)]
    [switch] $dim
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
}

$script:rootPath = Split-Path $script:MyInvocation.MyCommand.Path -Parent


function Blynclight()
{
    param([string] $controllerAssemblyPath, [string] $status, [bool] $dim)

    Write-Debug 'Found Embrava Blynclight software.'
    [System.Reflection.Assembly]::LoadFrom($controllerAssemblyPath) | Out-Null
    [Blynclight.BlynclightController] $controller = New-Object -Type 'Blynclight.BlynclightController'
    if ($null -eq $controller)
    {
        Write-Debug 'Unable to instantiate the controller class.'
        #$host.SetShouldExit(1)
        #[System.Environment]::Exit(1)
        return
    }

    [int] $numberOfDevices = $controller.InitBlyncDevices()
    if ($numberOfDevices -le 0)
    {
        Write-Debug 'No connected presence devices found.'
        #$host.SetShouldExit(1)
        #[System.Environment]::Exit(1)
        return
    }

    [int] $deviceId = 0
    Write-Debug "Using device ID '$deviceId'."

    # Write-Host "Switching status light to '$status'."

    Write-Debug "Setting color to '$status'."
    switch -exact ($status)
    {
        'blue'      { $controller.TurnOnBlueLight($deviceId) | Out-Null }
        'cyan'      { $controller.TurnOnCyanLight($deviceId) | Out-Null }
        'green'     { $controller.TurnOnGreenLight($deviceId) | Out-Null }
        'magenta'   { $controller.TurnOnMagentaLight($deviceId) | Out-Null }
        'orange'    { $controller.TurnOnOrangeLight($deviceId) | Out-Null }
        'red'       { $controller.TurnOnRedLight($deviceId) | Out-Null }
        'white'     { $controller.TurnOnWhiteLight($deviceId) | Out-Null }
        'yellow'    { $controller.TurnOnRGBLights($deviceId, 255, 255, 0) | Out-Null }

        'off'       { $controller.ResetLight($deviceId) | Out-Null; $dim = $false }

        default     { Write-Host "'$status' is not a recognized status."; $dim = $false }
    }

    if ($dim -eq $true)
    {
        Write-Debug 'Dimming light.'
        $controller.SetLightDim($deviceId) | Out-Null
    }

    # $controller.aoDevInfo[$deviceId] | fl

    #$controller.SelectLightFlashSpeed($deviceId, 3) | Out-Null
    #$controller.StartLightFlash($deviceId) | Out-Null
    #Start-Sleep -seconds 1
    #$controller.StopLightFlash($deviceId) | Out-Null

    $controller.CloseDevices($numberOfDevices)
    $controller = $null

    $host.SetShouldExit(0)
    [System.Environment]::Exit(0)
    exit 0
}


function KuandoBusylight()
{
    param([string] $controllerAssemblyPath, [string] $status, [bool] $dim)

    Write-Debug 'Found PLENOM Busylight software.'
    [System.Reflection.Assembly]::LoadFrom($controllerAssemblyPath) | Out-Null
    [Busylight.ISDK] $script:controller = New-Object -Type 'Busylight.SDK'
    if ($null -eq $controller)
    {
        Write-Debug 'Unable to instantiate the controller class.'
        #$host.SetShouldExit(1)
        #[System.Environment]::Exit(1)
        return
    }

    if ($controller.IsLightSupported -eq $false)
    {
        Write-Debug 'No connected presence devices found.'
        #$host.SetShouldExit(1)
        #[System.Environment]::Exit(1)
        return
    }

    Write-Debug "Setting color to '$status'."
    switch -exact ($status)
    {
        'blue'      { $controller.Light([Busylight.BusylightColor]::Blue) | Out-Null }
        'cyan'      { $controller.Light(128, 255, 255) | Out-Null }
        'green'     { $controller.Light([Busylight.BusylightColor]::Green) | Out-Null }
        'magenta'   { $controller.Light(128, 0, 255) | Out-Null }
        'orange'    { $controller.Light(255, 128, 0) | Out-Null }
        'red'       { $controller.Light([Busylight.BusylightColor]::Red) | Out-Null }
        'white'     { $controller.Light(255, 255, 255) | Out-Null }
        'yellow'    { $controller.Light([Busylight.BusylightColor]::Yellow) | Out-Null }

        'off'       { $controller.Light([Busylight.BusylightColor]::Off) | Out-Null }

        default     { Write-Host "'$status' is not a recognized status." }
    }

    $controller.Terminate()

    $host.SetShouldExit(0)
    [System.Environment]::Exit(0)
    exit 0
}

# Translate status into colors
switch -exact ($status)
{
    'available'     { $status = 'green' }
    'busy'          { $status = 'red' }
    'dnd'           { $status = 'magenta' }
    'away'          { $status = 'yellow' }
    'incoming'      { $status = 'blue' }
}

$controllers = @(
    ( $([System.IO.Path]::Combine("${env:ProgramFiles(x86)}", 'Embrava\Embrava Connect\blynclight.dll')),       { param($i) Blynclight $i $status $dim } ),
    ( $([System.IO.Path]::Combine($rootPath, 'devices\embrava\blynclight.dll')),                                { param($i) Blynclight $i $status $dim } ),
    ( $([System.IO.Path]::Combine("${env:UserProfile}", 'Documents\BusylightSDK\DOTNET4\BusylightSDK.dll')),    { param($i) KuandoBusylight $i $status $dim } ),
    ( $([System.IO.Path]::Combine($rootPath, 'devices\kuando\BusylightSDK.dll')),                               { param($i) KuandoBusylight $i $status $dim } )
)

$controllers | ForEach-Object {
    if ([System.IO.File]::Exists($_[0]) -eq $true)
    {
        $_[1].Invoke($_[0])
    }
}

$locations = ($controllers | ForEach-Object { $_[0] })
$message = 'Either no presence devices (Embrava Connect or PLENOM Busylight) are connected to the computer or the device software is not installed in any of the following locations: ' + $([System.String]::Join(', ', $locations)) + '.'
Write-Error $message
$host.SetShouldExit(1)
[System.Environment]::Exit(1)
exit 0
