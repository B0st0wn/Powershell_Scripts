# Get the name of the current computer
$computer = $env:COMPUTERNAME

# Check if Windows is already activated
$isActivated = Invoke-Command -ComputerName $computer { 
    # Use Get-CimInstance to retrieve information about installed software licensing products
    $activated = (Get-CimInstance -ClassName SoftwareLicensingProduct | 
                  Where-Object PartialProductKey | # Filter out products that do not have a partial product key (i.e. not installed)
                  Select-Object -ExpandProperty LicenseStatus) -contains 'Licensed' # Check if any installed products have a LicenseStatus of 'Licensed'
    return $activated
} -SessionOption (New-PSSessionOption -NoMachineProfile)

# If Windows is already activated, display a message and exit
if ($isActivated) {
    Write-Host "Windows is already activated."
} else {
    # If Windows is not activated, set the product key to use for activation
    $productKey = "WINDOWS_KEY"

    # Activate Windows using the specified product key
    Invoke-Command -ComputerName $computer { 
        # Use cscript.exe and slmgr.vbs to install the product key and activate Windows
        cscript.exe $env:SystemRoot\System32\slmgr.vbs -ipk $using:productKey
        cscript.exe $env:SystemRoot\System32\slmgr.vbs /ato 
    } -SessionOption (New-PSSessionOption -NoMachineProfile)

    # Display a message indicating that activation is complete
    Write-Host "Activation complete."
}

# Pause the script until the user presses Enter
Read-Host "Press Enter to exit."

