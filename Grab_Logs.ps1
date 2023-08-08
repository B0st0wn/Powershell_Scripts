# Function to check if we are running as administrator
function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if we are not running as an administrator
if (-not (Test-IsAdmin)) {
    # Relaunch the script with elevated rights
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $($MyInvocation.MyCommand.Definition)" -Verb RunAs
    return
}

# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Get all the log names
$logNames = Get-WinEvent -ListLog * | Select-Object -ExpandProperty LogName

# Create a new folder with the timestamp in the name
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$newFolder = New-Item -ItemType Directory -Path ".\Logs_$timestamp"

# Loop through the logs and export each to a .evtx file
foreach ($logName in $logNames) {
    try {
        # Replace slashes with underscores for filename compatibility
        $sanitizedName = $logName.Replace('/', '_')

        # Export the log
        Write-Host "Exporting $logName..."
        wevtutil epl $logName "$($newFolder.FullName)\$sanitizedName.evtx"
    }
    catch {
        Write-Warning "Failed to export $logName."
    }
}

# Ask user for save location using Save File Dialog
$saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
$saveFileDialog.Filter = "ZIP files (*.zip)|*.zip"
$saveFileDialog.Title = "Save the logs ZIP file"
$saveFileDialog.ShowDialog() | Out-Null
$zipPath = $saveFileDialog.FileName

# Ensure that a path was provided
if (-not [string]::IsNullOrWhiteSpace($zipPath)) {
    # Compress the logs into a ZIP file
    Compress-Archive -Path "$newFolder\*" -DestinationPath $zipPath -Force -CompressionLevel Optimal

    # Delete the uncompressed logs
    Remove-Item -Recurse -Force $newFolder

    Write-Host "Finished exporting and compressing logs to $zipPath."
}
else {
    Write-Warning "No save location selected. Aborting compression."
}
