<#Editor: Visual Studio Code
Script Name: DCU_Admin_Run_Only.ps1
Author: Paul Hanlon
Date: 04/18/2023
Description: 
  This PowerShell script forces Dell Command | Update to be run only by domain admin
#>


# Set the user/group name
$domainAdmins = "DOMAIN\Domain Admins"

# Check if Dell Command Update is installed in Program Files or Program Files (x86) folder
if (Test-Path -Path "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe") {
    $file = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"

    # Get the current access control list (ACL)
    $acl = Get-Acl $file

    # Create new access rules granting read and execute permission to Domain Admins
    $accessRuleDomainAdmins = New-Object System.Security.AccessControl.FileSystemAccessRule($domainAdmins, "ReadAndExecute", "Allow")

    # Add the new access rules to the ACL
    $acl.SetAccessRule($accessRuleDomainAdmins)

    # Apply the modified ACL to the file
    Set-Acl $file $acl
} elseif (Test-Path -Path "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe") {
    $file = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"

    # Get the current access control list (ACL)
    $acl = Get-Acl $file

    # Create new access rules granting read and execute permission to Domain Admins
    $accessRuleDomainAdmins = New-Object System.Security.AccessControl.FileSystemAccessRule($domainAdmins, "ReadAndExecute", "Allow")

    # Add the new access rules to the ACL
    $acl.SetAccessRule($accessRuleDomainAdmins)

    # Apply the modified ACL to the file
    Set-Acl $file $acl
} else {
    $appName = "Dell Command Update"
    $installAction = New-Object -ComObject 'UIResource.UIResourceMgr'
    $installableApps = $installAction.GetInstallableApplications() | Where-Object { $_.LocalizedDisplayName -eq $appName }

    if ($installableApps) {
        $installableApp = $installableApps[0]
        try {
            $installAction.InstallApplication($installableApp.DeploymentTypeId, $installableApp.RevisionId, $false, "", "", $true)
        } catch {
            Write-Error "Failed to install ${appName}: $_"
        }
    } else {
        Write-Error "Application $appName not found in Software Center"
    }
}
