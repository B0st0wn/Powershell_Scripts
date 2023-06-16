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

# Compress the logs into a ZIP file
$zipPath = "$($newFolder.FullName).zip"
Compress-Archive -Path "$newFolder\*" -DestinationPath $zipPath -CompressionLevel Optimal

# Delete the uncompressed logs
Remove-Item -Recurse -Force $newFolder

Write-Host "Finished exporting and compressing logs to $zipPath."
