<#Editor: Visual Studio Code
Script Name: vCenter_Win_Update.ps1
Author: Paul Hanlon
Date: 6/13/2023
Description: This PowerShell script automates the process of updating Windows-based VMs on a vCenter server. 
It takes a snapshot of each VM, installs security updates, checks for service errors, and outputs the results to a CSV file.
This was for a job that they didnt select me. Fuck them as it was their loss.#>

# Import the VMware PowerCLI module
Import-Module VMware.PowerCLI

# Import the Windows Update module
Import-Module PSWindowsUpdate

# Prompt for vCenter credentials
$vCenterCredentials = Get-Credential -Message "Enter your vCenter credentials"

# Connect to the vCenter server
Connect-VIServer -Server vCenter_Server -Credential $vCenterCredentials

# Create an array to hold the results
$results = @()

# Loop through each VM
foreach ($vm in $vmList) {
    $os = $vm.Guest.OSFullName

    # Check if the OS is Windows
    if ($os -like "*Windows*") {
        # Prompt for VM credentials
        $vmCredentials = Get-Credential -Message "Enter credentials for VM $($vm.Name)"

        # Get the IP address of the VM
        # Note: IPAddress[0] is used to select the first IP in case the VM has multiple network interfaces
        # IP address is not needed but captured for the csv file.
        $ipAddress = $vm.Guest.IPAddress[0]

        # Take a snapshot of the VM
        $snapshotName = "Pre-Windows-Updates"
        $snapshot = New-Snapshot -VM $vm -Name $snapshotName -Memory -Quiesce -Confirm:$false

        # Validate snapshot
        if ($snapshot) {
            Write-Host "Snapshot created successfully"
        } else {
            Write-Host "Snapshot creation failed"
            $results += New-Object PSObject -Property @{
                VM = $vm.Name
                IPAddress = $ipAddress
                Status = "Snapshot creation failed"
            }
            continue  # Skip this VM and continue with the next
        }

        # Get services before the update
        $servicesBefore = Invoke-VMScript -VM $vm -GuestUser $vmCredentials.UserName -GuestPassword $vmCredentials.GetNetworkCredential().Password -ScriptText "Get-Service | Where-Object {$_.Status -eq 'Running' -and $_.StartType -ne 'Disabled'} | Select-Object -ExpandProperty Name"

        # Run Windows updates remotely
        Invoke-VMScript -VM $vm -GuestUser $vmCredentials.UserName -GuestPassword $vmCredentials.GetNetworkCredential().Password -ScriptText {
            # Check for updates
            Get-WindowsUpdate -Online

            # Install updates
            $updates = Get-WindowsUpdate -Online | Where-Object { $_.Title -like "*Security Update*" }
            $updates | Install-WindowsUpdate -Confirm:$false
        }

        # Reboot the VM after updates
        Restart-VMGuest -VM $vm -Confirm:$false

        # Wait for the VM to restart in seconds.
        Start-Sleep -Seconds 600  # e.g., 10 minutes

        # Get services after the update and reboot
        $servicesAfter = Invoke-VMScript -VM $vm -GuestUser $vmCredentials.UserName -GuestPassword $vmCredentials.GetNetworkCredential().Password -ScriptText "Get-Service | Where-Object {$_.Status -eq 'Running' -and $_.StartType -ne 'Disabled'} | Select-Object -ExpandProperty Name"

        # Compare the services before and after the update
        $stoppedServices = Compare-Object -ReferenceObject $servicesBefore -DifferenceObject $servicesAfter -IncludeEqual -ExcludeDifferent |
            Where-Object { $_.SideIndicator -eq "<=" } |
            Select-Object -ExpandProperty InputObject

        # Add result to results array
        # Each result includes the VM name, IP address, the final update status, and stopped services
        $results += New-Object PSObject -Property @{
            VM = $vm.Name
            IPAddress = $ipAddress
            UpdateStatus = "Completed"
            StoppedServices = $stoppedServices -join ", "
        }
    }
}

# Output results to a CSV file
# The resulting CSV will have a row for each VM, with columns for the VM name, IP address, final update status, and stopped services
$results | Export-Csv -Path .\UpdateResults.csv -NoTypeInformation

# Disconnect from the vCenter server
Disconnect-VIServer -Confirm:$false
