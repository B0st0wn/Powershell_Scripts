<#Editor: Visual Studio Code
Script Name: Check_WinRM.ps1
Author: Paul Hanlon 
Date: 6/14/2023
Description: 
  This PowerShell script checks WinRM firewall rules are created and creates them if not found
#> 

# Check if running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script with administrative privileges."
    exit
}

# Enable WinRM in Windows Firewall
$firewallRuleName = "Windows Remote Management (HTTP-In)"
$firewallRule = Get-NetFirewallRule -Name $firewallRuleName -ErrorAction SilentlyContinue

if ($null -eq $firewallRule) {
    # Create the firewall rule if it doesn't exist
    $firewallRule = New-NetFirewallRule -DisplayName $firewallRuleName -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -Enabled True
    if ($null -eq $firewallRule) {
        Write-Host "Failed to create the firewall rule."
        exit
    }
    Write-Host "Firewall rule created successfully."
} elseif ($firewallRule.Enabled -eq $false) {
    # Enable the firewall rule if it exists but is disabled
    Set-NetFirewallRule -DisplayName $firewallRuleName -Enabled True
    Write-Host "Firewall rule enabled successfully."
} else {
    # Firewall rule already exists and is enabled
    Write-Host "Firewall rule already exists and is enabled."
}
