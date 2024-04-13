# Copyright (c) Stephan Adler.

@{
    RootModule = 'parsifal.network.psm1'
    ModuleVersion = '0.0.3.0'
    GUID = 'F13BF056-9F79-4BCD-9B5B-7416C7037706'

    CompatiblePSEditions = @("Core", "Desktop")
    PowershellVersion = "5.1"

    Author = 'Stephan Adler'
    CompanyName = 'Stephan Adler'
    Copyright = 'Copyright (c) Stephan Adler.'

    Description = "Network functions"

    NestedModules = @()

    RequiredAssemblies = @()

    FunctionsToExport = @(
        'Get-ExternalIpAddress',
        'Get-ExternalIpV4Address',

        'Test-MimeType'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # License for this module.
            LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

            # An icon representing this module.
            IconUri = 'https://stephanadler1.github.io/images/Nuget/Parsifal.png'

            Tags = @('PowerShell Module', 'Parsifal', 'Networking')
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
