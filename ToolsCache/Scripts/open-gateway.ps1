# -----------------------------------------------------------------------
# <copyright file="open-gateway.ps1" company="Stephan Adler">
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
        $DebugPreference = 'Continue'
        Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
    }
}

process {
    $script:routeTable = Get-NetRoute
    $script:gatewayAddress = $null
    $script:gatewayIp = $null

    $script:gateways = $routeTable |
        Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' } |
        Sort-Object RouteMetric |
        Select-Object NextHop
    if ($null -ne $gateways)
    {
        try {
            # Sometimes more than one default gateway can be configured, just use the first one.
            $gatewayIp = $gateways[0].NextHop
        }
        catch {
            $gatewayIp = $gateways.NextHop
        }

        $gatewayAddress = "http://$gatewayIp/"
    }
    else
    {
        $gateways = $routeTable |
        Where-Object { $_.DestinationPrefix -eq '::/0' } |
        Sort-Object RouteMetric |
        Select-Object NextHop
        if ($null -ne $gateways)
        {
            try {
                # Sometimes more than one default gateway can be configured, just use the first one.
                $gatewayIp = $gateways[0].NextHop
            }
            catch {
                $gatewayIp = $gateways.NextHop
            }

            $gatewayAddress = "http://[$gatewayIp]/"
        }
        else
        {
            return
        }
    }

    try
    {
        Write-Host 'Default gateway is' $gatewayIp

        Invoke-WebRequest -Uri $gatewayAddress -Method Get -TimeoutSec 1 -MaximumRedirection 0 | Out-Null
        Start-Process $gatewayAddress
        return
    }
    catch
    {
    }

    Write-Host 'No default gateway web site configured.'
}
