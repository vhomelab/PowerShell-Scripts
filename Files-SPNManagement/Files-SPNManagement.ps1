﻿<#
.SYNOPSIS
The script modifies the Nutanix Files computer account in Active Directory.

.DESCRIPTION
Use to add/remove Files SPN records from Files cluster computer object created in Active Directory.
Files when join to domain create 66 SPN records.
In some cases when the Failback workflow does not complete, stale entries of SPN records does not get removed.
Necessary permission are required, the user account must be member of Domain Admins, Enterprise Admins or must have delegated the appropriate authority.

.EXAMPLE
.\Files-SPNManagement.ps1 -Add -AddHostName Files-C -AddTo Files-B -DomainName Lab.com

Adds SPNs Host/Files-C.lab.com, Host/Files-C, Host/Files-C-1.lab.com, Host/Files-C-1 and so on, to computer account Files-B
.EXAMPLE
.\Files-SPNManagement.ps1 -Remove -RemoveHostName Files-C -RemoveFrom Files-B -DomainName Lab.com
#>

[cmdletbinding()]
param(
[Parameter(Mandatory=$true, Position=0, ParameterSetName="Add")]
[Switch]$Add,
[Parameter(Mandatory=$true, Position=1, ParameterSetName="Add",
HelpMessage = "Enter Files HostName you want to add, for example FilesA")]
[string]$AddHostName,
[Parameter(Mandatory=$true, Position=2, ParameterSetName="Add",
HelpMessage = "Enter Files HostName you want to add SPNs to, for example FilesA")]
[string]$AddTo,

[Parameter(Mandatory=$true, Position=0, ParameterSetName="Remove")]
[Switch]$Remove,
[Parameter(Mandatory=$true, Position=1, ParameterSetName="Remove",
HelpMessage = "Enter Files HostName you want to remove, for example FilesA")]
[string]$RemoveHostName,
[Parameter(Mandatory=$true, Position=2, ParameterSetName="Remove",
HelpMessage = "Enter Files HostName you want to remove SPNs from, for example FilesA")]
[string]$RemoveFrom,

[Parameter(Mandatory=$true, Position=0, ParameterSetName="List")]
[Switch]$List,
[Parameter(Mandatory=$true, Position=1, ParameterSetName="List")]
[string]$HostName,


[Parameter(Mandatory=$true, Position=3)]
[string]$DomainName
)


If($Add){
    Write-Host -BackgroundColor White -ForegroundColor Red "Performing Add operation"

    $ctr = 1
    while($ctr -le 32){
        Write-verbose "Adding Host/NTNX-$AddHostName-$ctr.$DomainName and Host/NTNX-$AddHostName-$ctr"
        Set-ADComputer -Identity $AddTo -ServicePrincipalNames @{Add="Host/NTNX-$AddHostName-$ctr.$DomainName","Host/NTNX-$AddHostName-$ctr"}
        Write-Host -ForegroundColor Green "Host/NTNX-$AddHostName-$ctr.$DomainName"
        write-host -ForegroundColor Green "Host/NTNX-$AddHostName-$ctr"
        Start-Sleep 2
        $ctr++
        if($ctr -gt 32){
            Write-verbose "Adding Host/NTNX-$AddHostName.$DomainName and Host/NTNX-$AddHostName"
            Set-ADComputer -Identity $AddTo -ServicePrincipalNames @{Add="Host/NTNX-$AddHostName.$DomainName","Host/NTNX-$AddHostName"}
            Write-Host -ForegroundColor Green "Host/NTNX-$AddHostName.$DomainName"
            Write-Host -ForegroundColor Green "Host/NTNX-$AddHostName"
        }
    }
}


if($Remove){
    Write-Host -BackgroundColor White -ForegroundColor Red "Performing Remove operation"

    $R1 = "Host/NTNX-$RemoveHostName"
    $R2 = "Host/$RemoveHostName"
    $R3 = "Host/$RemoveHostName.$DomainName"
    $RemoveSPNs = @($R1.ToUpper(), $R2.ToUpper(), $R3.ToUpper())

    $SPNlist = Get-ADComputer -Identity $RemoveFrom -Properties ServicePrincipalNames | Select-Object ServicePrincipalNames
    $SPNlist = $SPNlist.ServicePrincipalNames

    foreach($rSPN in $RemoveSPNs){
        Write-Verbose "Check $rSPN"
        foreach($SPN in $SPNlist){
        Write-Verbose "Checking $($rSPN) againest $SPN"
            if ($SPN -like "*$($rSPN)*"){
                Set-ADComputer -Identity $RemoveFrom -ServicePrincipalNames @{Remove="$SPN"}
                Write-Host -ForegroundColor Green "Found and removed $SPN"
                Start-Sleep 2
            }
        }
    }
}

if($List){
    (Get-ADComputer -Identity $HostName -Properties ServicePrincipalNames | Select-Object ServicePrincipalNames).ServicePrincipalNames
}