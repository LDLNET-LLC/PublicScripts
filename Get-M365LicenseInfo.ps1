<#

.SYNOPSIS

Get an M365 License Report of all members of a Commercial or Government Tenant M365 License Distribution. It will tell you what licneses they have based on if they have a mailbox enabled on their account.
The report will be in CSV Format and will output to a predetermined directory based on the Parameters set in the script.

 

.NOTES

    Name: Get-M365LicenseInfo

    Author: Lance Lingerfelt

    Version: 1.0

    Modify Date: 2023-08-24

    Parameter Values:

    $ReportsPath sets the path to a default directory and will create the directory if needed later in the script. Setting a value is NOT mandatory but script will setup a directory of C:\MatlockScripts\Reports
    $TenantEXO must use one of the following values: O365USGovGCCHigh or O365USGovDoD or O365Default (for commercial)
    $TenantAAD must use one of the following values: AzureUSGovernment or AzureCloud (for commercial)

.EXAMPLE

Connect to a Government Cloud Tenant in the Script

    .\Get-M365LicenseInfo.ps1 -TenantEXO O365USGovGCCHigh -TenantAAD AzureUSGovernment

Connect to Default Commerical Tenant in the Script

    .\Get-M365LicenseInfo.ps1 -TenantEXO O365Default -TenantAAD AzureCloud
#>

[CmdletBinding(SupportsShouldProcess = $true)]

Param(

    [Parameter(Mandatory = $false)]

    [string] $ReportsPath = "C:\LDLNETScripts\Reports",

    [Parameter(Mandatory = $true)]

    [ValidateSet("O365USGovGCCHigh","O365USGovDoD", "O365Default")]

    $TenantEXO,
    
    [Parameter(Mandatory = $true)]

    [ValidateSet("AzureUSGovernment","AzureCloud")]

    $TenantAAD

)

# ================================================
#               DO NOT MODIFY BEGIN
# ================================================

$ErrorActionPreference = 'SilentlyContinue'

$Date = Get-Date -Format "MM/dd/yyyy"

# Set Logging Configuration
$Log = [PSCustomObject]@{
    Path = "C:\LDLNETScripts\Logs\Get-M365LicenseInfo"
    Name = "$($Date).log"
}

# ================================================
#                DO NOT MODIFY END
# ================================================

# ================================================
#                   SCRIPT BEGIN
# ================================================

# Create New Logger Instance if Enabled
if ($PSCmdlet.ShouldProcess("Create New Logger Instance", $Log.Path)) {
    # Import Logger Module
    try {
        if ( -not (Get-Module -Name PoShLog -ListAvailable) ) {
            Install-Module -Name PoShLog -Scope CurrentUser -Force
        }
        else {
            Import-Module -Name PoShLog -Force
        }
    }
    catch {
        Write-Host -Object "Unable to import logger module. Error: $($_.Exception.Message)"
        exit 1
    }

    # Create New Logger Instance. Verbose logging level. Log to file and console. Start Logger.
    New-Logger | `
        Set-MinimumLevel -Value Verbose | `
        Add-SinkFile -Path "$($Log.Path)\$($Log.Name)" -OutputTemplate `
        '{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj}{NewLine}{Exception}' -RollingInterval Day | `
        Add-SinkConsole | `
        Start-Logger
    
    # Log Start of Script
    Write-VerboseLog "Start of Script."
}

if ($PSCmdlet.ShouldProcess("Create New Exchange Online Instance", $Log.Path)) {
    # Import ExchangeOnlineManagement Module
    try {
        if ( -not (Get-Module -Name ExchangeOnlineManagement -ListAvailable) ) {
            Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
        }
        else {
            Import-Module -Name ExchangeOnlineManagement -Force
        }
    }
    catch {
        Write-Host -Object "Unable to import ExchangeOnlineManagement module. Error: $($_.Exception.Message)"
        exit 1
    }

    if ($PSCmdlet.ShouldProcess("Create New AzureAD Instance", $Log.Path)) {
        # Import AzureAD Module
        try {
            if ( -not (Get-Module -Name AzureAD -ListAvailable) ) {
                Install-Module -Name AzureAD -Scope CurrentUser -Force
            }
            else {
                Import-Module -Name AzureAD -Force
            }
        }
        catch {
            Write-Host -Object "Unable to import AzureAD module. Error: $($_.Exception.Message)"
            exit 1
        }

    }

    # Connect to EXO via ExchangeOnlineManagement Module (GCCHigh)
    Write-VerboseLog "Connecting Exchange Online"
    #Connect-ExchangeOnline -ShowBanner:$false -ExchangeEnvironmentName O365USGovGCCHigh
    Connect-ExchangeOnline -ShowBanner:$false -ExchangeEnvironmentName $TenantEXO

    # Connect to AzureAD via AzureAD Module (GCCHigh)
    Write-VerboseLog "Connecting AzureAD"
    #Connect-AzureAD -AzureEnvironmentName AzureUSGovernment
    Connect-AzureAD -AzureEnvironmentName $TenantAAD

    # Get all users with a mailbox
    Write-VerboseLog "Getting User Mailbox List"
    $users = Get-Mailbox -resultsize Unlimited 

    # Initialize an array to store the results
    $licenseInfo = @()

    # Loop through each user to get their M365 license information
    Write-VerboseLog "Getting License Info For Each Mailbox User"
    foreach ($user in $users) {
        $userPrincipalName = $user.UserPrincipalName
        Write-Host "Checking [$userPrincipalName]" -ForegroundColor Green

        # Retrieve the user's M365 license information
        $userLicense = Get-AzureADUserLicenseDetail -ObjectId $user.ExternalDirectoryObjectId

        foreach ($License in $userLicense) {

            foreach ($SKU in $License) {
                Write-Host "Found License [$($SKU.SkuPartNumber)]" -ForegroundColor Cyan
                $licenseInfo += [PSCustomObject]@{
                    DisplayName = $user.DisplayName
                    UPN         = $userPrincipalName
                    License     = $SKU.SkuPartNumber
                    Services    = ""
                }
                foreach ($ServicePlan in $SKU) {
                    foreach ($Service in $ServicePlan.ServicePlans) {
                        Write-Host "Found Service [$($Service.ServicePlanName)]" -ForegroundColor White
                        $licenseInfo += [PSCustomObject]@{
                            DisplayName = $user.DisplayName
                            UPN         = $userPrincipalName
                            License     = ""
                            Services    = $Service.ServicePlanName 
                        }
                    }
                }
            }
        }
    } 
}
 
#Create Report Path if not there

if (Test-Path $ReportsPath) {
    #Do Nothing 
}
else {
    New-Item -Type Directory -Path $ReportsPath
}

#Export the Results   

$licenseInfo | Export-Csv $ReportsPath\M365_User_Licenses_$(Get-Date -Format yyyyMMddThhmmss).csv -notypeinformation

# Disconnect from Microsoft 365 PowerShell session
Disconnect-AzureAD -Confirm:$False
Disconnect-ExchangeOnline -Confirm:$False

Write-VerboseLog "End of Script"
# ================================================
#                   SCRIPT END
# ================================================