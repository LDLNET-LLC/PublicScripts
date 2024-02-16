#Set the PowerShell CLI for customization. 
#Written by Lance Lingerfelt / LDLNET LLC - lance.lingerfelt@ldlnet.net - http://www.ldlnet.net
#Make sure to read all the comments to make sure that you change and protect the values as needed!
#LDLNET LLC is not responsible for malicious or erroneous use of this script. RUN AT YOUR OWN RISK!!

#Start Script#

#Clear the default PowerShell Window
Clear-Host

#Run the Script Get-Weather.ps1 to get the weather forcast.
. $PSScriptRoot\Get-Weather.ps1
Get-Weather -City 'Charlotte' -Country 'USA' 

#Customize the PowerShell Window Settings
$console = $host.UI.RawUI
$size = $console.BufferSize
$size.Width = 172
$size.Height = 9999
$console.BufferSize = $size
$console.backgroundcolor = "black"
$size = $console.WindowSize
$size.Width = 172
$size.Height = 50
$console.WindowSize = $size


#Customize the text to be shown before the prompt
$foregroundColor = 'white'
$time = Get-Date
$psVersion= $host.Version.Major
$curUser= (Get-ChildItem Env:\USERNAME).Value
$curComp= (Get-ChildItem Env:\COMPUTERNAME).Value

### CHANGE THESE APPROPRIATE VALUES TO MATCH YOUR COMPANY SLOGAN OR WHATEVER YOU WANT IT TO SAY:
Write-Host "Welcome to COMPANY PowerShell, $curUser!" -foregroundColor $foregroundColor
Write-Host "Today is: $($time.ToLongDateString())" -foregroundColor Yellow
Write-Host "You're running PowerShell version: $psVersion" -foregroundColor Green
Write-Host "You are on Server: $curComp" -foregroundColor Gray
Write-Host "MY SLOGAN ROCKS! READ THE SCRIPT FOR CHANGES!" -foregroundcolor Cyan `n

#Customize the actual PS prompt
function Prompt {

$curtime = Get-Date -f "hh:mm:ss tt"

### CHANGE THESE VALUES TO MATCH YOUR COMPANY SLOGAN OR WHATEVER YOU WANT IT TO SAY:
Write-Host -NoNewLine "COMPANY: " -foregroundColor $foregroundColor
Write-Host -NoNewLine "MY SLOGAN ROCKS! READ THE SCRIPT FOR CHANGES! " -foregroundColor Green
Write-Host -NoNewLine "[" -foregroundColor Yellow
Write-Host -NoNewLine (Get-Date -f "hh:mm:ss tt") -foregroundColor $foregroundColor
Write-Host -NoNewLine "]" -foregroundColor Yellow
Write-Host -NoNewLine ">" -foregroundColor Red

### CHANGE THIS VALUE TO MATCH YOUR COMPANY SLOGAN OR WHATEVER YOU WANT IT TO SAY:
$host.UI.RawUI.WindowTitle = "CUSTOMIZED CHANGE ME PowerShell >> User: $curUser >> Current DIR: $((Get-Location).Path) >> Time: $curtime"

Return " "

}

#Azure Application Values to Connect MS Graph (ADD YOUR VALUES FOR THE APP FROM ENTRA/AZURE) YOUR SECURE PASSWORD FOR THE APP WILL BE VISIBLE SO DO NOT GIVE THIS SCRIPT OUT WITHOUT REMOVING THE VALUE!!!!!!

$ApplicationId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
$SecuredPassword = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$tenantID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"

$SecuredPasswordPassword = ConvertTo-SecureString `
-String $SecuredPassword -AsPlainText -Force

$ClientSecretCredential = New-Object `
-TypeName System.Management.Automation.PSCredential `
-ArgumentList $ApplicationId, $SecuredPasswordPassword

#Connect M365 Services

$ResponseMain = Read-Host "Do you want to connect all M365 PowerShell Service Modules? (Y/N)"
if ($ResponseMain.Substring(0, 1).ToUpper() -eq "Y") {

        Write-Host "Connecting Exchange Online" -ForegroundColor Green
        Connect-ExchangeOnline -ShowBanner:$false

        Write-Host "Connecting Azure-AD" -ForegroundColor Green
        Connect-AzureAD | Format-Table -a -wr
        
        ##ADD YOUR SHAREPOINT ADMIN URL BELOW:
        Write-Host "Connecting SharePoint Online" -ForegroundColor Green
        Connect-SPOService -Url 'https://xxxxxxx-admin.sharepoint.com' | Format-Table -a -wr

        Write-Host "Connecting Teams PowerShell" -ForegroundColor Green
        Connect-MicrosoftTeams | Format-Table -a -wr

        Write-Host "Connecting MSOnline PowerShell" -ForegroundColor Green
        Connect-MsolService

        Write-Host "Connecting Security Compliance PowerShell" -ForegroundColor Green
        Connect-IPPSSession

        Write-Host "Connecting MS Graph PowerShell" -ForegroundColor Green
        Connect-MgGraph -TenantId $tenantID -ClientSecretCredential $ClientSecretCredential -NoWelcome
}

else {
    Write-Host "Which Services to you wish to connect to?" -ForegroundColor Green
    $ResEXO = Read-Host "Do you want to connect to Exchange Online? (Y/N)"
        if ($ResEXO.Substring(0, 1).ToUpper() -eq "Y") {
            Write-Host "Connecting Exchange Online" -ForegroundColor Green
            Connect-ExchangeOnline -ShowBanner:$false
        }
    $ResAAD = Read-Host "Do you want to connect to Azure AD? (Y/N)"
        if ($ResAAD.Substring(0, 1).ToUpper() -eq "Y") {
            Write-Host "Connecting Azure-AD" -ForegroundColor Green
            Connect-AzureAD | Format-Table -a -wr
        }

        ##ADD YOUR SHAREPOINT ADMIN URL BELOW:
    $ResSPO = Read-Host "Do you want to connect to SharePoint Online? (Y/N)"
        if ($ResSPO.Substring(0, 1).ToUpper() -eq "Y") {
            Write-Host "Connecting SharePoint Online" -ForegroundColor Green
            Connect-SPOService -Url 'https://xxxxxxxxxx-admin.sharepoint.com' | Format-Table -a -wr
        }
    $ResMSOL = Read-Host "Do you want to connect to Microsoft Online Services? (Y/N)"
        if ($ResMSOL.Substring(0, 1).ToUpper() -eq "Y") {
            Write-Host "Connecting MSOnline PowerShell" -ForegroundColor Green
            Connect-MsolService
        }
    $ResTEAMS = Read-Host "Do you want to connect to Microsoft Teams? (Y/N)"
        if ($ResTEAMS.Substring(0, 1).ToUpper() -eq "Y") {
            Write-Host "Connecting Teams PowerShell" -ForegroundColor Green
            Connect-MicrosoftTeams | Format-Table -a -wr
        }
    $ResSEC = Read-Host "Do you want to connect to Microsoft Security and Compliance? (Y/N)"
        if ($ResSEC.Substring(0, 1).ToUpper() -eq "Y") {
            Write-Host "Connecting Security Compliance PowerShell" -ForegroundColor Green
            Connect-IPPSSession
        }
    $ResGRAPH = Read-Host "Do you want to connect to Microsoft Graph? (Y/N)"
        if ($ResGRAPH.Substring(0, 1).ToUpper() -eq "Y") {
            Write-Host "Connecting MS Graph PowerShell" -ForegroundColor Green
            Connect-MgGraph -TenantId $tenantID -ClientSecretCredential $ClientSecretCredential -NoWelcome
        }
}

Write-Host "==============="
Write-Host "PowerShell Connections Completed"

#End Script#