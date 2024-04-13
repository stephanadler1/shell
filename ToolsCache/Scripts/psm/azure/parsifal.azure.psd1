# Copyright (c) Stephan Adler.

@{
    RootModule = 'parsifal.azure.psm1'
    ModuleVersion = '0.0.2.0'
    GUID = 'A1E1B9AB-8065-4943-9A76-3D0EC64D235A'

    CompatiblePSEditions = @("Core", "Desktop")
    PowershellVersion = "5.1"

    Author = 'Stephan Adler'
    CompanyName = 'Stephan Adler'
    Copyright = 'Copyright (c) Stephan Adler.'

    Description = "Azure and Terraform functions"

    NestedModules = @(
        '..\core\parsifal.core.psd1'
    )

    RequiredAssemblies = @()

    FunctionsToExport = @(
        'Test-AzureCliVersion',
        'Request-AzureAccess',

        'Test-TerraformCurrent'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # License for this module.
            LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

            # An icon representing this module.
            IconUri = 'https://stephanadler1.github.io/images/Nuget/Parsifal.png'

            Tags = @('PowerShell Module', 'Parsifal', 'Azure', 'Terraform')
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
