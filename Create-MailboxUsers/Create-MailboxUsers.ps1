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

#region parameters
param(
    # CSV file path
    [Parameter(Mandatory=$true)][string]$csvpath,

    # Logging toggle
    [Parameter()][boolean]$log,

    # log path
    [parameter()][string]$logpath
)
