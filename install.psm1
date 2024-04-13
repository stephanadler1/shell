# -----------------------------------------------------------------------
# <copyright file="install.psm1" company="Stephan Adler">
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

Set-StrictMode -Version Latest

function script:ConvertPathToRegExpandSz
{
    param([string] $pathEnvVar)

    $rk = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey('Environment')
    $path = $rk.GetValue($pathEnvVar, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    $rk.DeleteValue($pathEnvVar, $false)

    if ($path)
    {
        $path = ''
    }

    $rk.SetValue($pathEnvVar, $path, [Microsoft.Win32.RegistryValueKind]::ExpandString)
}

function script:AddPath2
{
    param([string] $pathEnvVar, [string] $enviromentUserScope, [string] $path, [string] $environmentVariable, [string] $comment)

    # Expand the path and check if it is valid
    $expandedPath = [System.Environment]::ExpandEnvironmentVariables($path)
    if ([System.IO.Directory]::Exists($expandedPath) -eq $false)
    {
        return
    }

    Write-Host " * $comment from '$expandedPath'..."
    $rk = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey('Environment')
    $rk.DeleteValue($environmentVariable, $false)
    # $rk.SetValue($environmentVariable, $path, [Microsoft.Win32.RegistryValueKind]::ExpandString)
    [System.Environment]::SetEnvironmentVariable($environmentVariable, $expandedPath, $enviromentUserScope)

    $userPath = $rk.GetValue($pathEnvVar, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    $userPathElements = $userPath.Split(';', [System.StringSplitOptions]::RemoveEmptyEntries)
    $newUserPath = @()
    foreach($upe in $userPathElements)
    {
        if ([string]::Compare($upe, $expandedPath, [System.StringComparison]::OrdinalIgnoreCase) -eq 0)
        {
            continue
        }

        if ([string]::Compare($upe, "%$environmentVariable%", [System.StringComparison]::OrdinalIgnoreCase) -eq 0)
        {
            continue
        }

        $newUserPath += $upe
    }
    $userPath = [string]::Join(';', $newUserPath)

    if ($userPath.IndexOf("%$environmentVariable%", [StringComparison]::OrdinalIgnoreCase) -eq -1)
    {
        $userPath =("$userPath;%$environmentVariable%;")
        $userPath = $userPath.Replace(';;', ';').Trim(';')
        $rk.SetValue($pathEnvVar, $userPath, [Microsoft.Win32.RegistryValueKind]::ExpandString)
    }
}

function script:AddPath
{
    param([string] $pathEnvVar, [string] $enviromentUserScope, [string] $path, [string] $environmentVariable, [string] $comment)

    # There is a subtle difference in how environment variables are treated
    # based on the type of the value in the registry. See the system variables in
    # Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
    # and user variables in Computer\HKEY_CURRENT_USER\Environment.
    # PATH for system is REG_EXPAND_SZ, in user it's REG_SZ, which will prevent expansion
    # of user added path. Unfortunately no API to interact with environment variables directly
    # allows to specify the underlying storage type.

    # Expand the path and check if it is valid
    $expandedPath = [System.Environment]::ExpandEnvironmentVariables($path)
    if ([System.IO.Directory]::Exists($expandedPath) -eq $false)
    {
        return
    }

    Write-Host " * $comment from '$expandedPath'..."
    [System.Environment]::SetEnvironmentVariable($environmentVariable, $path, $enviromentUserScope)

    # PATH environment variable works on expanded path. Check if it is already
    # present and remove if so. Split the existing PATH into it's components and re-assemble
    # the parts that aren't equivalent to $expandedPath.
    $userPath = [System.Environment]::GetEnvironmentVariable($pathEnvVar, $enviromentUserScope)
    $userPathElements = $userPath.Split(';', [System.StringSplitOptions]::RemoveEmptyEntries)
    $newUserPath = @()
    foreach($upe in $userPathElements)
    {
        if ([string]::Compare($upe, $expandedPath, [System.StringComparison]::OrdinalIgnoreCase) -eq 0)
        {
            continue
        }

        $newUserPath += $upe
    }
    $userPath = [string]::Join(';', $newUserPath)

    if ($userPath.IndexOf($path, [StringComparison]::OrdinalIgnoreCase) -eq -1)
    {
        $userPath =($userPath + ';' + $expandedPath + ';')
        $userPath = $userPath.Replace(';;', ';')
        [System.Environment]::SetEnvironmentVariable($pathEnvVar, $userPath, $enviromentUserScope)
    }
}

function script:ScanThreats
{
    param([string] $path)

    if ([System.IO.Directory]::Exists($path) -eq $false)
    {
        return
    }

    [string] $avtool = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    if ([System.IO.File]::Exists($avtool) -eq $false)
    {
        Write-Host "AV Tool not found at '$avtool'."

        $avtool = "$env:ProgramFiles\Microsoft Security Client\Antimalware\MpCmdRun.exe"
        if ([System.IO.File]::Exists($avtool) -eq $false)
        {
            Write-Host "AV Tool not found at '$avtool'."
            return
        }
    }

    Write-Host "Scanning the '$path' to ensure no known threats..."
    $script:scanArgs = @(
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

function script:AddDesktopShortcut
{
    param([string] $shortcutName, [string] $targetPath, [string[]] $arguments, [string] $description, [string] $workingDirectory = $null, [string] $iconLocation = $null, [bool] $minimized = $false, $admin = $false)

    try {
        if ([System.String]::IsNullOrWhiteSpace($workingDirectory) -eq $true)
        {
            $workingDirectory = '%USERPROFILE%'
        }

        $windowStyle = 4
        if ($minimized)
        {
            $windowStyle = 7
        }

        $wshShell = New-Object -ComObject WScript.Shell
        $linkFile = ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), $shortcutName + ".lnk"))
        $shortcut = $wshShell.CreateShortcut($linkFile)
        $shortcut.TargetPath = $targetPath
        $shortcut.Arguments = [string]::Join(' ', $arguments)
        $shortcut.Description = $description
        $shortcut.WorkingDirectory = $workingDirectory
        $shortcut.WindowStyle = $windowStyle

        if ([System.String]::IsNullOrWhiteSpace($iconLocation) -ne $true)
        {
            $shortcut.IconLocation = $iconLocation
        }

        $shortcut.Save()

        if ($admin)
        {
            # mark shortcut as run as admin
            $bytes = [System.IO.File]::ReadAllBytes($linkFile)
            $bytes[0x15] = $bytes[0x15] -bor 0x20 # set byte 21 (0x15) bit 6 (0x20) ON
            [System.IO.File]::WriteAllBytes($linkFile, $bytes)
        }
    }
    catch {
        Write-Error "Creating shortcut '$shortcutName' caused exception '$_'."
    }
}

function script:ConfigureGit
{
    param([string] $scope, [string] $gitPath, [string] $key, [string] $value)
    $git = [System.Environment]::ExpandEnvironmentVariables("$gitPath\git.exe")
    $gitConfiguration = & $git 'config' $scope '--get' $key
    if (-not $gitConfiguration -or $gitConfiguration -ne $value)
    {
        & $git 'config' $scope $key $value
    }
}

function script:ConfigureGitGlobally
{
    # --global: Stored in the user profile.
    param([string] $gitPath, [string] $key, [string] $value)
    ConfigureGit '--global' $gitPath $key $value
}

function script:ConfigureGitSystemWide
{
    # --system: Stored next to the git.exe.
    param([string] $gitPath, [string] $key, [string] $value)
    ConfigureGit '--system' $gitPath $key $value
}

function script:CreateOrUpdateFolder
{
    param([string] $folderPath, [string] $folderIconFile, [string] $infoTip, [Array] $folderAttributes = $null)

    Write-Host "Setting up folder $folderPath..."

    # https://msdn.microsoft.com/en-us/library/windows/desktop/cc144102(v=vs.85).aspx
    $desktopIniFileContents = @(
        '[ViewState]', 'Mode=', 'Vid=', 'FolderType=Generic',
        '[.ShellClassInfo]', 'ConfirmFileOp=1')
    $desktopIniFilePath = [System.IO.Path]::Combine($folderPath, 'desktop.ini')
    $folderAttributes += @('+S', '+R')

    # Create folder and set SYSTEM + READONLY
    [System.IO.Directory]::CreateDirectory($folderPath) | Out-Null
    & attrib $folderAttributes "$folderPath" | Out-Null

    # Create desktop.ini file inside the folder
    if ([System.IO.File]::Exists($desktopIniFilePath) -eq $true)
    {
        & attrib -S -R -H "$desktopIniFilePath" | Out-Null
    }

    if ([System.String]::IsNullOrWhiteSpace($infoTip) -ne $true)
    {
        $desktopIniFileContents += "InfoTip=$infoTip"
    }

    if ([System.String]::IsNullOrWhiteSpace($folderIconFile) -ne $true)
    {
        if ([System.IO.File]::Exists($folderIconFile) -eq $true)
        {
            $desktopIniFileContents += "IconFile=$folderIconFile"
            $desktopIniFileContents += "IconIndex=0"
            $desktopIniFileContents += "IconResource=$folderIconFile,0"
        }
        else
        {
            $desktopIniFileContents += "IconResource=$folderIconFile"
        }
    }

    [System.IO.File]::WriteAllLines($desktopIniFilePath, $desktopIniFileContents, [System.Text.Encoding]::ASCII);

    & attrib +S +R +H "$desktopIniFilePath" | Out-Null
}

function script:IsSystemDriveOnSsd
{
    $private:osDriveLetter = $null
    if ($($env:SystemDrive).Length -eq 2)
    {
        $osDriveLetter = $($env:SystemDrive)[0]
    }

    if ($null -ne $osDriveLetter)
    {
        try
        {
            $private:partitionInfo = Get-Partition -DriveLetter $osDriveLetter
            $partitionInfo | ConvertTo-Json -Depth 1 | Write-Debug

            $private:diskInfo = Get-Disk -Number $partitionInfo.DiskNumber
            $diskInfo | ConvertTo-Json -Depth 1 | Write-Debug

            $private:physDiskInfo = Get-PhysicalDisk -UniqueId $diskInfo.UniqueId
            $physDiskInfo | ConvertTo-Json -Depth 1 | Write-Debug

            return ($physDiskInfo.MediaType -ieq 'SSD')
        }
        catch
        {
            return $false
        }
    }

    return $false
}

function script:GetActiveDirectoryUser
{
    param([string][ValidateNotNullOrEmpty()] $samAccountName)
    [Reflection.Assembly]::LoadWithPartialName('System.DirectoryServices.AccountManagement') | Out-Null
    [System.DirectoryServices.AccountManagement.PrincipalContext] $context = $null
    [System.DirectoryServices.AccountManagement.UserPrincipal] $user = $null
    try
    {
        Write-Host "Querying Active Directory for '$samAccountName'..."
        $context = New-Object -TypeName 'System.DirectoryServices.AccountManagement.PrincipalContext' -ArgumentList @([System.DirectoryServices.AccountManagement.ContextType]::Domain)
        $user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($context, [System.DirectoryServices.AccountManagement.IdentityType]::SamAccountName, $samAccountName)
        if ($null -ne $user)
        {
            Write-Host "Found Active Directory entry for '$samAccountName': $($user.DisplayName)."
            return $user
        }

        throw "User not found."
    }
    finally
    {
        if ($null -ne $context)
        {
            #$context.Dispose()
        }

        if ($null -ne $user)
        {
            #$user.Dispose()
        }
    }
}

function script:GetADUserFullName
{
    $user = GetActiveDirectoryUser($env:USERNAME)
    return $user.DisplayName
}

function script:GetEmailAddress
{
    return $emailAddress
}

function script:GetUserName
{
    return $userName
}

function script:GetPackageCacheRoot
{
    return $packageCacheRoot
}

function script:GetNugetCacheDirectory
{
    return $nugetCacheRoot
}

function script:GetNpmCacheDirectory
{
    return $npmCacheRoot
}

function script:SetSymbolServers
{
    param([string] $defaultSymbolPath, [string] $enviromentUserScope)

    [System.Environment]::SetEnvironmentVariable('_NT_SYMBOL_PATH', $defaultSymbolPath, $enviromentUserScope)
}

function script:SpecificDeveloperMachineSetup
{
}

