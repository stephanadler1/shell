# Copyright (c) Stephan Adler.

@{
    RootModule = 'script-collection.psm1'
    ModuleVersion = '0.0.1.0'
    GUID = '2D81950D-7089-4A12-AD81-55F8B6309089'

    CompatiblePSEditions = @("Core", "Desktop")
    PowershellVersion = "5.1"

    Author = 'Stephan Adler'
    CompanyName = 'Stephan Adler'
    Copyright = 'Copyright (c) Stephan Adler.'

    Description = "Shell helper functions"

    NestedModules = @(
        'psm\core\parsifal.core.psd1'
    )

    RequiredAssemblies = @()

    FunctionsToExport = @(
        'Get-DeveloperHomePath',
        'Get-SourceCodeRootPath',
        'Get-WorkingCopyRootPath',

        'Remove-Newline',

        'Test-FileExists',
        'Test-Git',
        'Test-Mercurial',
        'Test-SourceDepot',
        'Test-Subversion'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # License for this module.
            LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

            # An icon representing this module.
            IconUri = 'https://stephanadler1.github.io/images/Nuget/Parsifal.png'

            Tags = @('PowerShell Module', 'Developer Shell')
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
