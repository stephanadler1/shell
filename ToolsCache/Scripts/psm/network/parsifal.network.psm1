# Copyright (c) Stephan Adler.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}


Write-Debug 'Use TLS 1.2 or 1.3, don''t accept anything else.'
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13


function Get-ExternalIpAddress
{
    <#
    .SYNOPSIS
    Get the external IP address of your internet connection.

    .DESCRIPTION
    Returns the IPv4 address that the current computer uses when connecting
    to internet resources.
    #>

    param(
        [Parameter(Mandatory = $false)]
        [switch] $useCache = $false
    )

    if ($true -eq $useCache)
    {
       return Get-ExternalIpV4Address -useCache
    }

    return Get-ExternalIpV4Address
}


function Get-ExternalIpV4Address
{
    <#
    .SYNOPSIS
    Get the external IP address of your internet connection.

    .DESCRIPTION
    Returns the IPv4 address that the current computer uses when connecting
    to internet resources.
    See https://help.dyn.com/remote-access-api/checkip-tool/.
    #>

    param(
        [Parameter(Mandatory = $false)]
        [switch] $useCache = $false
    )

    $private:localIp = Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred `
        | Where-Object { ($_.PrefixOrigin -eq [System.Net.NetworkInformation.PrefixOrigin]::Dhcp) } `
        | Select-Object -First 1
    Write-Debug "Local IP address is $($localIp.IPAddress)."

    [string] $private:ipCacheFileName = [IO.Path]::GetFullPath([IO.Path]::Combine($env:TEMP, "public-ip-$($localIp.IPAddress).txt"))
    [System.IO.FileInfo] $private:ipCacheFile =  New-Object -TypeName System.IO.FileInfo -ArgumentList @($ipCacheFileName)
    [string] $private:userAgentString = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36'
    [string] $private:ipAddress = $null
    [bool] $private:writeCache = $true

    # If a cache file exists and it is not older than 1 hour, use the cached IP address.
    # DynDNS asks user to space requests at least 10 minutes apart.
    Write-Debug "Public IP address cache file is $($ipCacheFile.FullName)."
    if (($useCache -eq $true) -and ($ipCacheFile.Exists -eq $true) -and ($ipCacheFile.LastWriteTimeUtc -gt [System.DateTime]::UtcNow.AddHours(-1)))
    {
        Write-Debug "Use cached IP address."
        $ipAddress = [IO.File]::ReadAllText($ipCacheFile.FullName)
        $writeCache = $false
    }

    $private:ipRegex = "([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})"

    if ($true -eq [String]::IsNullOrWhitespace($ipAddress))
    {
        # Try DynDNS first. This site has very strict throttling limits!
        try {
            [string] $private:checkIpResult = Invoke-WebRequest -Uri 'http://checkip.dyndns.org:8245/' -Method Get `
                -MaximumRedirection 0 -UseBasicParsing -Timeout 5 `
                -UserAgent $userAgentString
            Write-Debug "Full result..: $checkIpResult"

            $private:checkIpParsed = Select-String -Pattern "(Current IP Address: )$ipRegex" -InputObject $checkIpResult

            if (($null -eq $checkIpParsed.Matches) -and ($checkIpParsed.Matches.Groups.Length -ne 2))
            {
                throw "No IP address found in '$checkIpResult'."
            }

            Write-Debug "IP address...: $($checkIpParsed.Matches.Groups[2])"

            $ipAddress = $checkIpParsed.Matches.Groups[2].Value
        }
        catch {
            # No op
        }
    }

    if ($true -eq [String]::IsNullOrWhitespace($ipAddress))
    {
        # Try Amazon AWS next.
        try {
            [string] $private:checkIpResult = Invoke-WebRequest -Uri 'https://checkip.amazonaws.com/' -Method Get `
                -MaximumRedirection 0 -UseBasicParsing -Timeout 5 `
                -UserAgent $userAgentString
            Write-Debug "Full result..: $checkIpResult"

            $private:checkIpParsed = Select-String -Pattern $ipRegex -InputObject $checkIpResult

            if (($null -eq $checkIpParsed.Matches) -and ($checkIpParsed.Matches.Groups.Length -ne 1))
            {
                throw "No IP address found in '$checkIpResult'."
            }

            Write-Debug "IP address...: $($checkIpParsed.Matches.Groups[1])"

            $ipAddress = $checkIpParsed.Matches.Groups[1].Value
        }
        catch {
            # No op
        }
    }

    if ($true -eq [String]::IsNullOrWhitespace($ipAddress))
    {
        throw 'External IP address could not be resolved.'
    }

    if ($true -eq $writeCache)
    {
        Write-Debug 'Write IP address to cache.'
        [IO.File]::WriteAllText($ipCacheFile.FullName, $ipAddress)
    }

    return $ipAddress
}


function Test-MimeType
{
    <#
    .SYNOPSIS
    Tests if the MIME type for the extension matches the expected MIME type.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $extension,

        [Parameter(Mandatory = $false)]
        [string] $expectedMimeType)

    $rk = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey($null, $false)
    $subKey = $rk.OpenSubKey($extension, $false)
    $mimeType = $subKey.GetValue('Content Type')
    if ([String]::Compare($expectedMimeType, $mimeType))
    {
        throw "Extension '$extension': The currently specified mime type of '$mimeType' does not match the expected type of '$expectedMimeType'. Add 'HKEY_CLASSES_ROOT\$extension\Content Type=(REG_SZ) $expectedMimeType' in the registry. You can use the following command line to modify the registry from an elevated command prompt: REG.EXE ADD `"HKEY_CLASSES_ROOT\$extension`" /v `"Content Type`" /t REG_SZ /d `"$expectedMimeType`" /f ."
    }

    Write-Debug "Extension '$extension' is set to mime type '$expectedMimeType'."

    $rk.Close()
}
