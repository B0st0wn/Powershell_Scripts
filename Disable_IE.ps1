# Define the log file path
$logFilePath = "C:\IE_Disabled\IE_Log.txt"

# Check if the folder exists, if not create it
if(!(Test-Path -Path "C:\IE_Disabled")) {
    New-Item -ItemType directory -Path "C:\IE_Disabled"
}

# Checking whether Internet Explorer 11 is enabled or not
$ieStatus = Get-WindowsOptionalFeature -Online -FeatureName Internet-Explorer-Optional-amd64

# If IE is enabled, this will disable it
if ($ieStatus.State -eq 'Enabled') {
    # Log information
    Add-Content -Path $logFilePath -Value "$(Get-Date) - Internet Explorer 11 is enabled. I am going to disable it now."

    # Disabling Internet Explorer 11
    Disable-WindowsOptionalFeature -Online -FeatureName Internet-Explorer-Optional-amd64 -NoRestart

    # Log the action of disabling IE11
    Add-Content -Path $logFilePath -Value "$(Get-Date) - Internet Explorer 11 has been successfully disabled."
    
    # Output an exit code of 69
    exit 69
}
else {
    # Log the information that IE11 was not enabled
    Add-Content -Path $logFilePath -Value "$(Get-Date) - Internet Explorer 11 is not enabled on your system."
    
    # Output an exit code of 69
    exit 69
}
