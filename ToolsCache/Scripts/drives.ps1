# -----------------------------------------------------------------------
# <copyright file="convert-date.ps1" company="Stephan Adler">
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

.DESCRIPTION
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $global:DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

Write-Host


Get-Disk | Format-List

Get-Volume | Format-Table -AutoSize -Wrap

$driveTypeStrings = @(
    'Unknown',
    'No Root Directory',
    'Removable Disk',
    'Local Disk',
    'Network Drive',
    'Compact Disc',
    'RAM Disk'
)

function DriveTypeToString
{
    param(
        [int] $driveType
    )

    if ($driveType -ge $driveTypeStrings.length)
    {
        return "$driveType"
    }

    return $driveTypeStrings[$driveType] + " ($driveType)"
}

$mediaTypeStrings = @(
    'Unknown',
    '5.25" Floppy 1.2 MB',
    '3.5" Floppy 1.44 MB',
    '3.5" Floppy 2.88 MB',
    '3.5" Floppy 20.8 MB',
    '3.5" Floppy 720 KB',
    '5.25" Floppy 360 KB',
    '5.25" Floppy 320 KB',
    '5.25" Floppy 320 KB',
    '5.25" Floppy 180 KB',
    '5.25" Floppy 160 KB',
    'Removable Not Floppy',
    'Fixed Hard Disk'
)

function MediaTypeToString
{
    param(
        [int] $mediaType
    )

    if ($mediaType -ge $mediaTypeStrings.length)
    {
        return "$mediaType"
    }

    return $mediaTypeStrings[$mediaType] + " ($mediaType)"
}


$size1MB = 1024 * 1024
$size1GB = $size1MB * 1024

function FormatSize
{
    param(
        [long] $sizeInBytes
    )

    if ($sizeInBytes -gt $size1GB)
    {
        return "$([Math]::Round($sizeInBytes/$size1GB,3)) GB"
    }


    if ($sizeInBytes -gt $size1MB)
    {
        return "$([Math]::Round($sizeInBytes/$size1MB,3)) MB"
    }

    return "$($sizeInBytes) B "
}

if ($env:OS -ieq "WINDOWS_NT")
{
    Write-Host 'Using https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-logicaldisk:'

    $private:drives = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $env:COMPUTERNAME
    $drives `
        | Format-Table -AutoSize -Wrap `
            DeviceID,Description,VolumeName,`
            @{Label='FreeSpace';Expression={FormatSize $_.FreeSpace};Alignment='right'}, `
            @{Label='Size';Expression={FormatSize $_.Size};Alignment='right'},
            @{Label='DriveType';Expression={DriveTypeToString $_.DriveType}},
            @{Label='MediaType';Expression={MediaTypeToString $_.MediaType}},
            Compressed,FileSystem `

    $drives `
        | Select-Object DeviceID,LastErrorCode,ErrorDescription,ErrorCleared `
        | Format-Table -AutoSize -Wrap
}
