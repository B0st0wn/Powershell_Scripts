# Check if Windows is already activated
$isActivated = (Get-CimInstance -ClassName SoftwareLicensingProduct |
                Where-Object PartialProductKey | # Filter out products without a partial product key (i.e. not installed)
                Select-Object -ExpandProperty LicenseStatus) -contains 'Licensed' # Check if any products have a 'Licensed' status

# If Windows is already activated, display a message and exit
if ($isActivated) {
    Write-Host "Windows is already activated."
} else {
    # Product key
    $productKey = "#####-#####-#####-#####-#####" # Replace "WINDOWS_KEY" with your actual product key

    # Activate Windows using the hardcoded product key
    slmgr -ipk $productKey
    slmgr /ato

    # Display a message indicating that activation is complete
    Write-Host "Activation attempt complete. Please check if Windows is activated."
}

# Pause the script with a clearer prompt message
Read-Host "Press Enter to exit the script."