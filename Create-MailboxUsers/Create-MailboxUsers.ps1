<#

.SYNOPSIS
Create User account and mailbox in Exchange 2013 environment using data from .csv

.DESCRIPTION
Use this script to create user accounts in Active Directory and corresponding Exchange mailbox.
The .CSV sample file is provided along with this script.

.PARAMETER help

.EXAMPLE

.NOTES
Author: Vaseem Mohammed (vaseem.mohammed@nutanix.com)
Revision: 28th March 2021

#>

#region ---- parameters ----
param(
    # CSV file path
    [Parameter(Mandatory = $true)] [string]$csvpath,

    # Logging toggle
    [Parameter()] [boolean]$log,

    # log path
    [parameter()] [string]$logpath
)
#endregion ---- parameters ----

#region ---- functions ----

# function Write-LogOutput
function Write-LogOutput
    {

        [CmdletBinding(DefaultParameterSetName = 'None')] #make this function advanced

        param
        (
            [Parameter(Mandatory)]
            [ValidateSet('INFO','WARNING','ERROR','SUM','SUCCESS','STEP','DEBUG','DATA')]
            [string]
            $Category,

            [string]
            $Message,

            [string]
            $LogFile
        )

        process
        {
            $Date = get-date #getting the date so we can timestamp the output entry
            $FgColor = "Gray" #resetting the foreground/text color
            switch ($Category) #we'll change the text color depending on the selected category
            {
                "INFO" {$FgColor = "Green"}
                "WARNING" {$FgColor = "Yellow"}
                "ERROR" {$FgColor = "Red"}
                "SUM" {$FgColor = "Magenta"}
                "SUCCESS" {$FgColor = "Cyan"}
                "STEP" {$FgColor = "Magenta"}
                "DEBUG" {$FgColor = "White"}
                "DATA" {$FgColor = "Gray"}
            }

            Write-Host -ForegroundColor $FgColor "$Date [$category] $Message" #write the entry on the screen
            if ($LogFile) #add the entry to the log file if -LogFile has been specified
            {
                Add-Content -Path $LogFile -Value "$Date [$Category] $Message"
            }
        }

    }#end function Write-LogOutput

    # Check Organization unit exist, if not, create one.

    # Collect Users with Mailbox enabled, store SAMAccountName

#endregion ---- functions ----


#region ---- initialization ----

# check for Exchange Powershell snapin
#$InstalledModules = Get-Module
try{
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-LogOutput -Category ERROR -Message "Active Directory Module is not available, Install/Enable AD DS Tools from Roles Administrations tools "
}
Start-Sleep 2

$PSSnapins = Get-PSSnapin
if($PSSnapins.Name -match "Microsoft.Exchange") {
    Write-Warning "Exchange 2010 Snap-In already loaded, import not required!"
} else {
    Add-PSSnapin Microsoft.Exchange.Management.Powershell.E2010 -ErrorAction SilentlyContinue
    }
#endregion ---- initialization ----


