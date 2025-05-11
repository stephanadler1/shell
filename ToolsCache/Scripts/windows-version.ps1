# -----------------------------------------------------------------------
# <copyright file="windows-version.ps1" company="Stephan Adler">
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

begin {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
    {
        $global:DebugPreference = 'Continue'
        Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
    }
}

process {

    Write-Host
    Write-Host 'Windows Version Information'
    Write-Host '---------------------------'
    Write-Host
    Write-Host '... based on registry information.'
    Write-Host 'The list of ReleaseId values is at [Windows 10 - Release information](https://docs.microsoft.com/en-us/windows/windows-10/release-information).'
    Write-Host 'The list of InstallationType values can be found at [Determining Whether Server Core Is Running](https://msdn.microsoft.com/en-us/library/ee391629(v=vs.85).aspx)'

    Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | Format-List *
    Get-CimInstance Win32_OperatingSystem | Format-List *

    Write-Host 'Use the windows command "systeminfo" and "msinfo32" to get more detailed information about the running operating system.'

    Get-CimInstance Win32_ComputerSystem | Format-List *
}
