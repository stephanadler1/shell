# -----------------------------------------------------------------------
# <copyright file="install.ps1" company="Stephan Adler">
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
The script configures the host operating system in a way that makes it consistent across all
my computers. It assumes that the system is partitioned into 2 drives/partitions:

* C:\ ($env:SYSTEMDRIVE) - the operating system drive
* D:\ ($dataDrive)       - the data drive

Instead of letting the script discover the $dataDrive, it can be provided as an input parameter to the script.

The following DESKTOP SHORTCUTS are being created

* Command Shell - The ConEmu version of the cmd.exe default shell.
* Developer Shell - The ConEmu version of the Visual Studio Developer Command Line.
* Developer Shell (PS) - The ConEmu PowerShell enabled Developer Shell (not quite ready yet!)
* PowerShell Shell - The ConEmu version of the Windows PowerShell.

The following FOLDERS are being created

* $dataDrive\dev                 - folder containing source code ($sourceCodeFolder)
* $dataDrive\packages            - the local package cache root folder ($packageCacheRoot)
* $dataDrive\packages\n          - the local NuGet package cache root folder ($nugetCacheRoot)
* $dataDrive\packages\n\r        - the local NuGet repository folder ($nugetRepositoryDirectory)
* $dataDrive\packages\n\g        - the local NuGet global cache folder ($nugetGlobalCacheDirectory)
* $dataDrive\packages\npm        - the local NPM package cache root folder ($npmCacheRoot)
* $dataDrive\Symbols             - is setup as the cache folder for debug symbols ($symbolCacheDirectory)
* $dataDrive\users               - secondary folder for user profile data ($secondaryUsersFolder)
* $dataDrive\users\$env:USERNAME - the secondary $env:USERPROFILE folder for the current user, including ACL'ing consistent with $env:USERPROFILE ($secondaryUserFolder).

The following TOOLS are being installed into the $env:PATH and their own environment variables starting with TOOLS_*.

* Converts the user's $env:PATH to REG_EXPAND_SZ, usually it is REG_SZ.
* $toolsRootPath - is the root of the tools cache. It is being added to $env:PATH and $env:TOOLS. It contains many *.cmd files that hook up lesser used tools, like OpenSSL, Python, NMap, MSBuild, NuGet, Notepad++. This provides an easy way to extend the tools coverage without overloading $env:PATH and adversely affecting the system's performance.
* Sysinternals are installed into $env:PATH and $env:TOOLS_SYSINTERNALS.
* Gnu Tools are installed into $env:PATH and $env:TOOLS_GNUWINCORETOOLS.
* Git is installed into $env:PATH and $env:TOOLS_GIT.
* Various tools located in $toolsRootPath\Various are installed into $env:PATH and $env:TOOLS_VARIOUS.

The global GIT configuration is adjusted to

* user.name is set to 'Stephan Adler'
* user.email is set to the result of the GetEmailAddress method.
* Many useful aliases are created in the global scope, like nb (new branch), co (checkout), st (status), pause (pause work), start (start/resume work).

NUGET is preconfigured in the following way:

* It is available through $env:PATH.
* The cache folder is $nugetCacheDirectory and $env:NugetMachineInstallRoot.
* The $sourceCodeFolder contains a NuGet.config file (template is in $toolsRootPath\Scripts\NuGet.config.template.xml ($nugetConfigFile) that sets the cache directories to $nugetCacheDirectory.

The DEBUG SYMBOL CACHE is setup up

* in folder $symbolCacheDirectory
* and symbol servers are configured in $env:_NT_SYMBOL_PATH.

.LINK
https://github.com/stephanadler1/shell/blob/master/install.md
#>

[CmdletBinding()]
param(
    # Provide a drive letter where you want to place your user data. D: is used if writeable otherwise $env:SYSTEMDRIVE is used.
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({[System.IO.Directory]::Exists($_) -eq $true})]
    [string] $dataDrive = $null,

    # The default user name used for Git.
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $userName = 'Stephan Adler',

    # The default email address used for Git.
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $emailAddress = 'dev@example.com',

    # Name of the folder holding source code/enlistments.
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $sourceCodeFolderName = 'dev',

    #
    [Parameter(Mandatory = $false)]
    [string] $shortcutPath = $null
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $global:DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

[bool] $runningArm64 = ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64')

# -----------------------------------------------------------------------
# Auto-detecting the data drive
# -----------------------------------------------------------------------

if ([string]::IsNullOrEmpty($dataDrive) -eq $true)
{
    # Trying to auto-detect the data drive on D:
    if ([System.IO.Directory]::Exists('D:\') -eq $true)
    {
        $tempFileName = 'D:\' + [System.Guid]::NewGuid().ToString('N')
        try
        {
            # Check if the drive let's us write to it (DEV-SEAT-1 case with mapped drives from ARCTURUS)
            [System.IO.File]::WriteAllText($tempFileName, 'test')
            $dataDrive = 'D:\'
        }
        catch
        {
            # do nothing
        }
        finally
        {
            [System.IO.File]::Delete($tempFileName)
        }
    }

    if ([string]::IsNullOrEmpty($dataDrive) -eq $true)
    {
        # Auto-detection didn't work, assume the $env:SystemDrive, usually C:
        $dataDrive = $env:SystemDrive
    }
}

# Make sure the drive ends with \
$dataDrive = ($dataDrive.TrimEnd('\') + '\')


# -----------------------------------------------------------------------
# Determine the root path of the tools
# -----------------------------------------------------------------------

$script:rootPath = Split-Path $script:MyInvocation.MyCommand.Path -Parent

if ([string]::IsNullOrEmpty($shortcutPath))
{
    $shortcutPath = [System.IO.Path]::Combine($dataDrive, 'DevTools')
}

if ([System.IO.Directory]::Exists($shortcutPath) -eq $false)
{
    New-Item -ItemType Junction -Path $shortcutPath -Target $rootPath | Out-Null
}

# retain the original path, if it is already set.
$script:rootPathOrig = $env:TOOLS_ORIG
if ([string]::IsNullOrWhiteSpace($rootPathOrig) -eq $true)
{
    $rootPathOrig = $rootPath
}

$rootPath = $shortcutPath


# -----------------------------------------------------------------------
# Set the defaults
# -----------------------------------------------------------------------

$script:toolsRootPath = ([System.IO.Path]::Combine($rootPath, 'ToolsCache'))
$script:toolsRootOrigPath = ([System.IO.Path]::Combine($rootPathOrig, 'ToolsCache'))
$script:pathEnvVar = 'PATH'
[System.EnvironmentVariableTarget] $script:enviromentUserScope = [System.EnvironmentVariableTarget]::User

$script:icaclsAddUserCheck = "$($env:USERDOMAIN)\$($env:USERNAME):(OI)(CI)(F)"
$script:icaclsAddUser = @(
    '/grant', $icaclsAddUserCheck,
    '/c')

$script:icaclsUserOnly = @(
    '/grant:r', "NT AUTHORITY\SYSTEM:(OI)(CI)(F)",
    '/grant:r', "BUILTIN\Administrators:(OI)(CI)(F)"
    '/grant:r', "$($env:USERDOMAIN)\$($env:USERNAME):(OI)(CI)(F)",
    '/inheritance:r',
    '/c')

[int] $script:parallalism = [int]::Parse($env:NUMBER_OF_PROCESSORS) * 2
if ($parallalism -le 0)
{
    $parallalism = 4
}


$iconLockScreen = '%WINDIR%\System32\Shell32.dll,47'
$iconLogoff = '%WINDIR%\System32\Shell32.dll,27'
#$iconStatus = '%WINDIR%\System32\Shell32.dll,265' # clock icon
$iconStatus = '%WINDIR%\System32\Shell32.dll,238' # recycle icon
#$iconLego = ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\FolderIcon-Lego.ico'))
#$iconGroup = ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\FolderIcon-Group.ico'))
$iconLego = "$env:WINDIR\System32\Shell32.dll,80"
$iconGroup = "$env:WINDIR\System32\Shell32.dll,160"

if ([string]::IsNullOrWhiteSpace($env:OneDrive) -eq $false)
{
    if ($toolsRootPath.StartsWith($env:OneDrive))
    {
        $toolsRootPath = $toolsRootPath.Replace($env:OneDrive, '%OneDrive%')
    }
}

$script:toolsRootPathExpanded = [System.Environment]::ExpandEnvironmentVariables($toolsRootPath)

if ([string]::IsNullOrWhiteSpace($toolsRootPathExpanded) -eq $true)
{
    Write-Error '$toolsRootPathExpanded is empty.'
    return 1
}


[string] $script:sourceCodeFolder = '*** NOT DEFINED ***'
if ([string]::IsNullOrEmpty($env:SOURCES_ROUT))
{
    # This will be the default.
    $sourceCodeFolder = [System.IO.Path]::Combine($dataDrive, $sourceCodeFolderName)

    # Let's check a couple of folders that might be used instead of the
    # default configured in $sourceCodeFolderName.
    [array] $checkFolderNames = @('src', 'git')
    foreach($testFolderName in $checkFolderNames)
    {
        $testFolder = [System.IO.Path]::Combine($dataDrive, $testFolderName)
        if ($true -eq (Test-Path -Path $testFolder))
        {
            $sourceCodeFolder = $testFolder
            break
        }
    }
}
else
{
    $sourceCodeFolder = $env:SOURCES_ROOT
}

$script:secondaryUsersFolder = $null
$script:packageCacheRoot = [System.IO.Path]::Combine($dataDrive, 'packages')
$script:nugetCacheRoot = [System.IO.Path]::Combine($packageCacheRoot, 'n')
$script:npmCacheRoot = [System.IO.Path]::Combine($packageCacheRoot, 'npm')


# -----------------------------------------------------------------------
# Import Customization Script
# -----------------------------------------------------------------------

Import-Module "$rootPath\install.psm1" -Scope Local
if ([System.IO.File]::Exists("$rootPath\install.$env:USERDOMAIN.psm1"))
{
    Import-Module "$rootPath\install.$env:USERDOMAIN.psm1" -Scope Local -Force
}

$packageCacheRoot = $(GetPackageCacheRoot)
$nugetCacheRoot = $(GetNugetCacheDirectory)
$script:nugetRepositoryDirectory = [System.IO.Path]::Combine($nugetCacheRoot, 'r')
$script:nugetGlobalCacheDirectory = [System.IO.Path]::Combine($nugetCacheRoot, 'g')
$npmCacheRoot = $(GetNpmCacheDirectory)


# -----------------------------------------------------------------------
# Print standard configuration
# -----------------------------------------------------------------------

Write-Host
Write-Host 'Configuration'
Write-Host "  Tools Root.........: $toolsRootPath"
Write-Host "  Original Tools Root: $toolsRootOrigPath"
Write-Host "  Data Drive.........: $dataDrive"
Write-Host "  Source Code Folder.: $sourceCodeFolder"
Write-Host "  Package Cache Root.: $packageCacheRoot"
Write-Host "  NPM Cache Root.....: $npmCacheRoot"
Write-Host "  Nuget Cache Root...: $nugetCacheRoot"
Write-Host "    Repository cache.: $nugetRepositoryDirectory"
Write-Host "    Global Cache.....: $nugetGlobalCacheDirectory"
Write-Host "  User name..........: $(GetUserName)"
Write-Host "  Email address......: $(GetEmailAddress)"
Write-Host

# -----------------------------------------------------------------------
# Test can be added here
# -----------------------------------------------------------------------

<#
AddDesktopShortcut 'Update Status' '"%COMSPEC%"' @('/q', '/d', '/c', "`"$toolsRootOrigPath\toggle-status.cmd`"") -iconlocation $iconStatus -minimized $true
exit 1
#>

# -----------------------------------------------------------------------
# Scanning for threats
# -----------------------------------------------------------------------

ScanThreats $rootPath


# -----------------------------------------------------------------------
# Source Code Folder
# -----------------------------------------------------------------------

CreateOrUpdateFolder $sourceCodeFolder $iconLego 'Source code folder. Environment variable SOURCES_ROOT points to it.' @('+I')
[string] $script:existingAcls = & icacls $sourceCodeFolder
if ($existingAcls.Contains($icaclsAddUserCheck) -eq $false)
{
	Write-Host "Re-acling folder $sourceCodeFolder"
	& icacls $sourceCodeFolder $icaclsAddUser | Out-Null
}

[System.Environment]::SetEnvironmentVariable('SOURCES_ROOT', $sourceCodeFolder, $enviromentUserScope)

# Copy directory.build.(props|targets) files into the source code folders to detect poorly written code
$directoryBuildFile = [System.IO.Path]::Combine($sourceCodeFolder, 'directory.build.props')
if ([System.IO.File]::Exists($directoryBuildFile) -ne $true)
{
    Copy-Item ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\directory.build.props.template.xml')) -Destination $directoryBuildFile -Force
    & attrib +R "$directoryBuildFile" | Out-Null
}

$directoryBuildFile = [System.IO.Path]::Combine($sourceCodeFolder, 'directory.build.targets')
if ([System.IO.File]::Exists($directoryBuildFile) -ne $true)
{
    Copy-Item ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\directory.build.targets.template.xml')) -Destination $directoryBuildFile -Force
    & attrib +R "$directoryBuildFile" | Out-Null
}

$directoryBuildFile = [System.IO.Path]::Combine($toolsRootPath, 'directory.shortcuts.json')
if ([System.IO.File]::Exists($directoryBuildFile) -ne $true)
{
    # no global file exists, so check in the sources root folder
    $directoryBuildFile = [System.IO.Path]::Combine($sourceCodeFolder, 'directory.shortcuts.json')
    if ([System.IO.File]::Exists($directoryBuildFile) -ne $true)
    {
        Copy-Item ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\directory.shortcuts.json.template.json')) -Destination $directoryBuildFile -Force
        & attrib +R "$directoryBuildFile" | Out-Null
    }
}

$editorConfigFile = [System.IO.Path]::Combine($sourceCodeFolder, '.editorconfig')
if ([System.IO.File]::Exists($editorConfigFile) -ne $true)
{
    Copy-Item ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\editorconfig.template.ini')) -Destination $editorConfigFile -Force
    & attrib +R "$editorConfigFile" | Out-Null
}


# -----------------------------------------------------------------------
# Secondary User Folder
# -----------------------------------------------------------------------

if (-not ($dataDrive.StartsWith($env:SystemDrive, [System.StringComparison]::OrdinalIgnoreCase)))
{
    # Only create a new user folder if it is not the SYSTEMDRIVE!
    $script:secondaryUsersFolder = [System.IO.Path]::Combine($dataDrive, 'Users')
    CreateOrUpdateFolder $secondaryUsersFolder $iconGroup 'Secondary user profile folder.'

    $secondaryUserFolder = [System.IO.Path]::Combine($secondaryUsersFolder, $env:USERNAME)
    if ([System.IO.Directory]::Exists($secondaryUserFolder) -ne $true)
    {
        [System.IO.Directory]::CreateDirectory($secondaryUserFolder) | Out-Null
        & icacls $secondaryUserFolder $icaclsUserOnly | Out-Null
    }
    else
    {
        Write-Host "$secondaryUserFolder $icaclsUserOnly"
    }
}


# -----------------------------------------------------------------------
# Add tools path to PATH environment variable
# -----------------------------------------------------------------------

Write-Host 'Installing tools in PATH...'
ConvertPathToRegExpandSz $pathEnvVar
AddPath2 $pathEnvVar $enviromentUserScope $toolsRootPath 'TOOLS' 'Tools'
[System.Environment]::SetEnvironmentVariable('TOOLS_ORIG', $rootPathOrig, $enviromentUserScope)

[string] $script:sysinternalsPath = 'Sysinternals'
if ($true -eq $runningArm64)
{
	$sysinternalsPath = 'Sysinternals\ARM64'
}
AddPath2 $pathEnvVar $enviromentUserScope ([System.IO.Path]::Combine($toolsRootPath, $sysinternalsPath)) 'TOOLS_SYSINTERNALS' 'Sysinternals'
AddPath2 $pathEnvVar $enviromentUserScope ([System.IO.Path]::Combine($toolsRootPath, 'Various')) 'TOOLS_VARIOUS' 'Various Tools'
AddPath2 $pathEnvVar $enviromentUserScope ([System.IO.Path]::Combine($toolsRootPath, 'GnuWin32.CoreTools\bin')) 'TOOLS_GNUWINCORETOOLS' 'GnuWin 32 Core Tools'

$script:gitPath = [System.IO.Path]::Combine($toolsRootPath, 'git.vsts\cmd')
if ([System.IO.Directory]::Exists([System.Environment]::ExpandEnvironmentVariables($gitPath)) -ne $true)
{
    $gitPath = [System.IO.Path]::Combine($toolsRootPath, 'git.portable\cmd')
    if ($true -eq $runningArm64)
    {
        $gitPath = [System.IO.Path]::Combine($toolsRootPath, 'ARM64\git.portable\cmd')
    }

    if ([System.IO.Directory]::Exists([System.Environment]::ExpandEnvironmentVariables($gitPath)) -ne $true)
    {
        $gitPath = [System.IO.Path]::Combine($toolsRootPath, 'git\cmd')
    }
}

AddPath2 $pathEnvVar $enviromentUserScope $gitPath 'TOOLS_GIT' 'Git'

# Installing Node.js
$script:nodePath = [System.IO.Path]::Combine($toolsRootPath, 'node')
if ([System.IO.Directory]::Exists([System.Environment]::ExpandEnvironmentVariables($nodePath)) -eq $true)
{
    AddPath2 $pathEnvVar $enviromentUserScope $nodePath 'TOOLS_NODE' 'Node.js'
}

# Installing Java Runtime Environment
$script:javaPath = [System.IO.Path]::Combine($toolsRootPath, 'Java\bin')
if ([System.IO.Directory]::Exists([System.Environment]::ExpandEnvironmentVariables($javaPath)) -eq $true)
{
    AddPath2 $pathEnvVar $enviromentUserScope $javaPath 'TOOLS_JAVA' 'Java Runtime Environment'

    $script:javaRootPath = [System.IO.Path]::GetFullPath([System.Environment]::ExpandEnvironmentVariables([System.IO.Path]::Combine($javaPath, '..')))

    # Path of the JDK (Java Development Kit), always part of the SE downloads
    [System.Environment]::SetEnvironmentVariable('JAVA_HOME', $javaRootPath, $enviromentUserScope)

    # Path of the JRE (Java Runtime Environment), always part of the SE downloads
    [System.Environment]::SetEnvironmentVariable('JRE_HOME', $javaRootPath, $enviromentUserScope)
}

# Installing GraphViz
$script:graphVizPath = [System.Environment]::ExpandEnvironmentVariables([System.IO.Path]::Combine($toolsRootPath, 'GraphViz\bin\dot.exe'))
if ([System.IO.File]::Exists($graphVizPath) -eq $true)
{
    [System.Environment]::SetEnvironmentVariable('GRAPHVIZ_DOT', $graphVizPath, $enviromentUserScope)
}


# -----------------------------------------------------------------------
# Configure preferred PowerShell version
# -----------------------------------------------------------------------

$script:preferredPowerShell = 'pwsh.exe'
Write-Host 'Configuring preferred PowerShell version...'
& where.exe $preferredPowerShell | Out-Null
if ($LASTEXITCODE -eq 0)
{
    [System.Environment]::SetEnvironmentVariable('TOOLS_PS', $preferredPowerShell, $enviromentUserScope)
}
else
{
    [System.Environment]::SetEnvironmentVariable('TOOLS_PS', 'powershell.exe', $enviromentUserScope)
}


# -----------------------------------------------------------------------
# Disable Telemetry Gathering
# -----------------------------------------------------------------------

# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_telemetry?view=powershell-7.4
[System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '1', $enviromentUserScope)

# https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-environment-variables#net-sdk-and-cli-environment-variables
[System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', '1', $enviromentUserScope)

# https://learn.microsoft.com/en-us/cli/azure/azure-cli-configuration
[System.Environment]::SetEnvironmentVariable('AZURE_CORE_COLLECT_TELEMETRY', '0', $enviromentUserScope)


# -----------------------------------------------------------------------
# Configure the command shell
# -----------------------------------------------------------------------

Write-Host 'Configuring command processor...'
[System.Environment]::SetEnvironmentVariable('DIRCMD', '/ogn', $enviromentUserScope)

if ([System.Environment]::OSVersion.Version.Major -ge 10)
{
    # https://superuser.com/questions/413073/windows-console-with-ansi-colors-handling
    [System.Environment]::SetEnvironmentVariable('PROMPT', '$E[m$E[32m$T$S$E[92m$P$E[90m$_$E[90m$G$E[m$S$E]9;12$E\', $enviromentUserScope)
}
else
{
    # This is the original Windows command prompt
    [System.Environment]::SetEnvironmentVariable('PROMPT', '$P$G$S', $enviromentUserScope)
}


# -----------------------------------------------------------------------
# Create Desktop Shortcuts if ConEmu is available
# -----------------------------------------------------------------------

if ($true -eq $runningArm64)
{
    Write-Host "Use Windows Terminal instead."
}
else
{
    $script:conEmuPath = ([System.IO.Path]::Combine($toolsRootOrigPath, 'ConEmu\ConEmu64.exe'))
    if ([System.IO.File]::Exists([System.Environment]::ExpandEnvironmentVariables($conEmuPath)) -eq $true)
    {
        Write-Host 'Set ConEmu Desktop shortcuts...'
        # AddDesktopShortcut 'Command Shell' $conEmuPath @('-run', "`"$env:COMSPEC`"") 'Command Processor in ConEmu64' 'd:\dev'
        # AddDesktopShortcut 'Developer Shell' $conEmuPath @('-run', "`"$env:COMSPEC`"", '/k', "`"$rootPath\initdev.cmd`"") 'Developer Command Processor in ConEmu64' 'd:\dev'
        AddDesktopShortcut 'Command Shell' $conEmuPath @('-run', '"%COMSPEC%"', '/d', '/k', "`"title Command Prompt`"") 'Command Processor in ConEmu64' -workingDirectory "$env:HOMEDRIVE\$env:HOMEPATH" -iconLocation "$($conEmuPath),3"
        AddDesktopShortcut 'Developer Shell' $conEmuPath @('-run', '"%COMSPEC%"', '/d', '/s', '/k', "`"`"$rootPath\initdev.cmd`"`"") 'Developer Command Processor in ConEmu64' -workingDirectory "$sourceCodeFolder" -iconLocation "$($conEmuPath),3"
        AddDesktopShortcut 'PowerShell Shell' $conEmuPath @('-run', '"%TOOLS_PS%"') 'PowerShell in ConEmu64' -workingDirectory "$sourceCodeFolder" -iconLocation "$($conEmuPath),3"
        AddDesktopShortcut 'Developer Shell (PS)' $conEmuPath @('-run', '"%TOOLS_PS%"', '-NoLogo', '-NoExit', '-Mta', '-ExecutionPolicy RemoteSigned', '-File', "`"$rootPath\initdev.ps1`"") 'Developer Command Processor (PS) in ConEmu64' -workingDirectory "$sourceCodeFolder" -iconLocation "$($conEmuPath),3"
    }
    else
    {
        Write-Host "Unable to find ConEmu at '$conEmuPath'."
    }
}

# https://www.tenforums.com/tutorials/77458-rundll32-commands-list-windows-10-a.html
# rundll32.exe user32.dll, LockWorkStation
AddDesktopShortcut 'Lock Computer' '"%WINDIR%\System32\rundll32.exe"' @('user32.dll,LockWorkStation') -iconLocation $iconLockScreen -minimized $true
AddDesktopShortcut 'Sign Out Computer' '"%WINDIR%\System32\logoff.exe"' @('') -iconLocation $iconLogoff -minimized $true
AddDesktopShortcut 'Update Presence Status' '"%COMSPEC%"' @('/q', '/d', '/c', "`"$toolsRootOrigPath\toggle-status.cmd`"") 'Windows Defender: stop miscategorizing this link as Trojan:Win32/Phonzy.C!ml' -iconlocation $iconStatus -minimized $true


# -----------------------------------------------------------------------
# Create Symbols directory and environment variables
# -----------------------------------------------------------------------

$script:symbolCacheDirectory = [System.IO.Path]::Combine($dataDrive, 'Symbols')
Write-Host "Configure Symbol cache to be $symbolCacheDirectory..."
[System.IO.Directory]::CreateDirectory($symbolCacheDirectory) | Out-Null

# Compress the folder, prevent indexing, give current user full access
& compact /c "$symbolCacheDirectory" | Out-Null
& attrib +I "$symbolCacheDirectory" /s /d | Out-Null
$existingAcls = & icacls $symbolCacheDirectory
if (-not $existingAcls.Contains($icaclsAddUserCheck))
{
	Write-Host "Re-acling folder $symbolCacheDirectory"
	& icacls $symbolCacheDirectory $icaclsAddUser | Out-Null
}

$script:defaultSymbolPath = "SRV*$symbolCacheDirectory*https://msdl.microsoft.com/download/symbols;SRV*$symbolCacheDirectory*https://referencesource.microsoft.com/symbols"
# Invalid: ;SRV*$symbolCacheDirectory*http://srv.symbolsource.org/pdb/Public
SetSymbolServers $defaultSymbolPath $enviromentUserScope


# -----------------------------------------------------------------------
# Configure the Windows Terminal
# -----------------------------------------------------------------------

$script:windowsTerminalConfigPath = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $windowsTerminalConfigPath)
{
    Write-Host 'Windows Terminal installation found. Applying customization...'
    $script:windowsTerminalConfig = Get-Content -Path $windowsTerminalConfigPath | ConvertFrom-Json

    $script:terminalProfile = @{
        guid = "{7817925a-5c89-4d2e-a8f4-03f79bb0de8e}"
        hidden = $false
        name = "Developer Shell"
        commandline = '"%COMSPEC%" /d /s /k ""%TOOLS%\..\initdev.cmd""'
        startingDirectory = "%SOURCES_ROOT%"
        icon = "%TOOLS%\Scripts\FolderIcon-Lego.ico"
        fontFace = "Consolas"
        fontSize = 11
        colorScheme = "DevShell"
        useAcrylic = $false
    }

    # Check if the profile exists
    $script:existingProfile = $windowsTerminalConfig.profiles.list | Where-Object { $_.guid -ieq $terminalProfile.guid }
    if ($null -eq $existingProfile)
    {
        Write-Host 'Installing Terminal profile...'
        $windowsTerminalConfig.profiles.list += $terminalProfile
		$windowsTerminalConfig.defaultProfile = $terminalProfile.guid
    }

    $script:terminalScheme = @{
        name = "DevShell"
        foreground = "#FDF6E3"
        background = "#002B36"
        cursorColor = "#FFFFFF"
        brightBlack = "#93A1A1"
        brightBlue = "#268BD2"
        brightGreen = "#4FB636"
        brightCyan = "#2AA198"
        brightRed = "#DC322F"
        brightPurple = "#D33682"
        brightYellow = "#B58900"
        brightWhite = "#FDF6E3"
        black = "#002B36"
        blue = "#073642"
        green = "#008080"
        cyan = "#3182A4"
        red = "#CB4B16"
        purple = "#9C36B6"
        yellow = "#859900"
        white = "#EEE8D5"
    }

    # Check if the schema exists
    $script:existingSchema = $windowsTerminalConfig.schemes | Where-Object { $_.name -ieq $terminalScheme.name }
    if ($null -eq $existingSchema)
    {
        Write-Host 'Installing Terminal schema...'
        $windowsTerminalConfig.schemes += $terminalScheme
    }

	# Other customizations
    SetWindowsTerminalSetting $windowsTerminalConfig 'wordDelimiters' ' '

	$windowsTerminalConfig | ConvertTo-Json -Depth 100 | Write-Debug
    $windowsTerminalConfig | ConvertTo-Json -Depth 100 | Set-Content -Path $windowsTerminalConfigPath
}


# -----------------------------------------------------------------------
# Configure developer machine
# -----------------------------------------------------------------------

SpecificDeveloperMachineSetup


# -----------------------------------------------------------------------
# Setup NuGet cache directory
# -----------------------------------------------------------------------

if ($null -ne $packageCacheRoot)
{
    try {
        Write-Host "Configure package root to be $packageCacheRoot..."
        [System.IO.Directory]::CreateDirectory($packageCacheRoot) | Out-Null
        # Compress the folder, prevent indexing, give current user full access
        & compact /c "$packageCacheRoot" | Out-Null
        & attrib +I "$packageCacheRoot" /s /d | Out-Null
        & icacls $packageCacheRoot $icaclsAddUser | Out-Null
    }
    catch {
        Write-Warning $_
    }
}

if ($null -ne $nugetCacheRoot)
{
    try {
        Write-Host "Configure Nuget cache to be $nugetCacheRoot..."
        [System.IO.Directory]::CreateDirectory($nugetCacheRoot) | Out-Null
        # Compress the folder, prevent indexing, give current user full access
        & compact /c "$nugetCacheRoot" | Out-Null
        & attrib +I "$nugetCacheRoot" /s /d | Out-Null
        & icacls $nugetCacheRoot $icaclsAddUser | Out-Null
    }
    catch {
        Write-Warning $_
    }
}

# Configure NuGet for the source code folder based on template file
$nugetConfigFile = [System.IO.Path]::Combine($sourceCodeFolder, 'NuGet.config')
if ([System.IO.File]::Exists($nugetConfigFile) -ne $true)
{
    Copy-Item ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\NuGet.config.template.xml')) -Destination $nugetConfigFile -Force
}

# Set cache paths
Write-Host "Configure Nuget repository to be $nugetRepositoryDirectory..."
Write-Host "Configure Nuget global package folder to be $nugetGlobalCacheDirectory..."
& attrib -R "$nugetConfigFile" | Out-Null
& "$toolsRootPathExpanded\nuget.cmd" config -set "repositoryPath=$nugetRepositoryDirectory" -set "globalPackagesFolder=$nugetGlobalCacheDirectory"  -configFile $nugetConfigFile
& attrib +R "$nugetConfigFile" | Out-Null


# -----------------------------------------------------------------------
# Setup NPM cache directory
# -----------------------------------------------------------------------

if ($null -ne $npmCacheRoot)
{
    try {
        # See https://docs.npmjs.com/misc/config

        Write-Host "Configure NPM cache to be $npmCacheRoot..."
        [System.IO.Directory]::CreateDirectory($npmCacheRoot) | Out-Null
        # Compress the folder, prevent indexing, give current user full access
        & compact /c "$npmCacheRoot" | Out-Null
        & attrib +I "$npmCacheRoot" /s /d | Out-Null
        & icacls $npmCacheRoot $icaclsAddUser | Out-Null

        [System.Environment]::SetEnvironmentVariable('NPM_CONFIG_CACHE', $npmCacheRoot, $enviromentUserScope)
    }
    catch {
        Write-Warning $_
    }
}


# -----------------------------------------------------------------------
# Configure Git
# -----------------------------------------------------------------------

Write-Host "Configuring global Git settings for '$(GetUserName)'..."
# Environment variables to consider: https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables
# Configure Git behavior.
# - ConfigureGitGlobally will place the configuration into the user profile on the machine.
# - ConfigureGitSystemWide will place the configuration into the git.exe folder location.
#
# Prefer ConfigureGitGlobally for the following reasons:
# 1. The config is not overwritten by a new git version
# 2. The configuration can be specific to the context/domain membership of the machine.
ConfigureGitGlobally $gitPath 'core.longpaths' 'true'
ConfigureGitGlobally $gitPath 'user.name' $(GetUserName)
ConfigureGitGlobally $gitPath 'user.email' $(GetEmailAddress)
ConfigureGitGlobally $gitPath 'pull.ff' 'only'
ConfigureGitGlobally $gitPath 'credential.helper' 'manager'
ConfigureGitGlobally $gitPath 'credential.helperselector.selected' 'manager'

# Increase parallelism of fetch/clone operations
# See https://git-scm.com/docs/git-config
ConfigureGitGlobally $gitPath 'fetch.parallel' "$parallalism"
ConfigureGitGlobally $gitPath 'submodule.fetchJobs' "$parallalism"

# See https://github.com/git-ecosystem/git-credential-manager/blob/main/docs/azrepos-users-and-tokens.md
# and https://github.com/git-ecosystem/git-credential-manager/blob/main/docs/configuration.md#credentialazreposcredentialtype
ConfigureGitGlobally $gitPath 'credential.azreposCredentialType' 'oauth'

# Activate recording of resolved conflicts, so that identical conflict hunks can be resolved automatically,
# should they be encountered again. By default, git-rerere(1) is enabled if there is an rr-cache directory
# under the $GIT_DIR, e.g. if "rerere" was previously used in the repository.
ConfigureGitGlobally $gitPath 'rerere.enabled' 'true'

# More aliases to consider
# http://haacked.com/archive/2014/07/28/github-flow-aliases/
# http://durdn.com/blog/2012/11/22/must-have-git-aliases-advanced-examples/
#
# Dynamically get the default branch of the repository, see
# https://stackoverflow.com/questions/28666357/git-how-to-get-default-branch
ConfigureGitGlobally $gitPath 'alias.br' 'branch -v'
ConfigureGitGlobally $gitPath 'alias.co' 'checkout'
ConfigureGitGlobally $gitPath 'alias.com' '!f() { db=$(basename $(git symbolic-ref refs/remotes/origin/HEAD)); git checkout $db; }; f'
ConfigureGitGlobally $gitPath 'alias.cod' 'checkout develop'
ConfigureGitGlobally $gitPath 'alias.cl' 'clean -fdxq'
ConfigureGitGlobally $gitPath 'alias.db' '!f() { db=$(basename $(git symbolic-ref refs/remotes/origin/HEAD)); echo $db; }; f'
ConfigureGitGlobally $gitPath 'alias.gh' '!f() { cid=$(git rev-parse head); echo $cid; echo $cid | clip; }; f'
ConfigureGitGlobally $gitPath 'alias.hist' "log --pretty=format:'%C(yellow)%h %Cred%ad%Creset | %s%d %Cblue[%an]' --graph --date=short"
ConfigureGitGlobally $gitPath 'alias.lol' 'log --graph --oneline'
ConfigureGitGlobally $gitPath 'alias.nb' '!f() { bn=${1-zzz_temp$RANDOM}; un=${USERNAME,,}; db=$(basename $(git symbolic-ref refs/remotes/origin/HEAD)); git checkout -b dev/$un/$bn origin/$db; git push --set-upstream origin dev/$un/$bn; }; f'
ConfigureGitGlobally $gitPath 'alias.nf' '!f() { bn=${1-zzz_temp$RANDOM}; db=$(basename $(git symbolic-ref refs/remotes/origin/HEAD)); git checkout -b feature/$bn origin/$db; git push --set-upstream origin feature/$bn; }; f'
ConfigureGitGlobally $gitPath 'alias.nr' '!f() { bn=${1-zzz_temp$RANDOM}; un=${USERNAME,,}; git push origin --delete dev/$un/$bn; git branch -d dev/$un/$bn; }; f'
ConfigureGitGlobally $gitPath 'alias.st' 'status'
ConfigureGitGlobally $gitPath 'alias.up' "!f() { git pl --rebase; }; f"
ConfigureGitGlobally $gitPath 'alias.wipe' "!f() { git add -A; git commit -qm '*** WIPED SAVEPOINT ***. Use git reflog to restore.'; git reset HEAD~1 --hard; }; f"
ConfigureGitGlobally $gitPath 'alias.pause' "!f() { git add -A; git commit -m '*** SAVEPOINT ***. Use git start to resume work.'; }; f"
ConfigureGitGlobally $gitPath 'alias.start' 'reset HEAD~1 --mixed'
ConfigureGitGlobally $gitPath 'alias.rbm' '!f() { db=$(basename $(git symbolic-ref refs/remotes/origin/HEAD)); git fetch --prune --auto-gc; git rebase --no-autostash origin/$db;  git submodule update --init --recursive; }; f'
ConfigureGitGlobally $gitPath 'alias.rbd' '!f() { git fetch --prune --auto-gc; git rebase --no-autostash origin/develop; git submodule update --init --recursive; }; f'
ConfigureGitGlobally $gitPath 'alias.rhm' '!f() { db=$(basename $(git symbolic-ref refs/remotes/origin/HEAD)); git fetch --prune --auto-gc; git reset --hard origin/$db;  git submodule update --init --recursive; }; f'
ConfigureGitGlobally $gitPath 'alias.rhd' '!f() { git fetch --prune --auto-gc; git reset --hard origin/develop; git submodule update --init --recursive; }; f'
ConfigureGitGlobally $gitPath 'alias.delete' '!f() { bn=${1-zzz_temp$RANDOM}; db=$(basename $(git symbolic-ref refs/remotes/origin/HEAD)); git fetch --prune --auto-gc; git checkout $db; git branch -d $bn; git push origin --delete $bn; }; f'
ConfigureGitGlobally $gitPath 'alias.remove' '!f() { bn=${1-zzz_temp$RANDOM}; db=$(basename $(git symbolic-ref refs/remotes/origin/HEAD)); git fetch --prune --auto-gc; git checkout $db; git branch -D $bn; git push origin --delete $bn; }; f'
# ConfigureGitGlobally $gitPath 'alias.nw' '!f() { bn=${1-zzz_temp$RANDOM}; un=${USERNAME,,}; git worktree add --track -b dev/$un/$bn \dev\$bn master; git branch --set-upstream-to origin dev/$un/$bn; }; f'
ConfigureGitGlobally $gitPath 'alias.pf' 'push --force-with-lease'
ConfigureGitGlobally $gitPath 'alias.pl' "!f() { git pull --prune $@; git submodule update --init --recursive; }; f"

# https://github.blog/2022-04-12-git-security-vulnerability-announced/
# The ceiling directories are being set in initdev.cmd if they are not yet defined.
[System.Environment]::SetEnvironmentVariable('GIT_CEILING_DIRECTORIES', $sourceCodeFolder, $enviromentUserScope)
AddPath2 'GIT_CEILING_DIRECTORIES' $enviromentUserScope '%SOURCES_ROOT%' 'SOURCES_ROOT' 'Git Ceiling directories'

# -----------------------------------------------------------------------
# Configure WSL
# -----------------------------------------------------------------------

$wslConfigFile = [System.IO.Path]::Combine($env:USERPROFILE, '.wslconfig')
if ([System.IO.File]::Exists($nugetConfigFile) -ne $true)
{
    Copy-Item ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\.wslconfig.template.txt')) -Destination $wslConfigFile -Force
}


Write-Host 'Done.'

