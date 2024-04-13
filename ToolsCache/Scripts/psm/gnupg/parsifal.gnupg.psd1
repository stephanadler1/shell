# Copyright (c) Stephan Adler.

@{
    RootModule = 'parsifal.gnupg.psm1'
    ModuleVersion = '0.0.2.0'
    GUID = '9E61A8FF-F543-42E4-9C33-483B33AEF182'

    CompatiblePSEditions = @("Core", "Desktop")
    PowershellVersion = "5.1"

    Author = 'Stephan Adler'
    CompanyName = 'Stephan Adler'
    Copyright = 'Copyright (c) Stephan Adler.'

    Description = "GnuPG functions"

    NestedModules = @(
        '..\core\parsifal.core.psd1'
    )

    RequiredAssemblies = @()

    FunctionsToExport = @(
        'Unprotect-GnuPgFile',
        'Protect-GnuPgFile'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # License for this module.
            LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

            # An icon representing this module.
            IconUri = 'https://stephanadler1.github.io/images/Nuget/Parsifal.png'

            Tags = @('PowerShell Module', 'Parsifal', 'GnuPG', 'GPG')
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
