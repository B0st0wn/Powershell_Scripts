<
#Editor: Visual Studio Code
Script Name: Test.ps1
Author: Paul Hanlon
Date: 6/16/2023
Description: 
  This PowerShell script checks if the service named "ADSync" is running. 
  If the service is not found, an error is thrown and logged. 
  If the service is found but not running, it starts the service and logs the event.
  The script also creates a log file. If a log file already exists, it zips the old log file and creates a new one. 
  If a zip file does not exist, it creates one.
#>

$serviceName = "ADSync" # Replace with the correct service name if different

# Create the folder if it doesn't exist
$folderPath = "$env:PUBLIC\Desktop\Tasks Log"
if (!(Test-Path -Path $folderPath)){
    New-Item -ItemType Directory -Force -Path $folderPath
}

# Set the path for the log file, with the current time in the filename
$logFileName = "{0}_Check_{1:HHmmss}.txt" -f $serviceName, (Get-Date)
$logPath = Join-Path -Path $folderPath -ChildPath $logFileName

# Create the log file
$null = New-Item -Path $logPath -ItemType File -Force

# Redirect verbose and error messages to the log file
Start-Transcript -Path $logPath -Force

# Check if the service exists and is not running, then start it
try {
    $service = Get-Service -Name $serviceName -ErrorAction Stop
    if ($service.Status -eq 'Stopped') {
        Start-Service -Name $serviceName -ErrorAction Stop
        Write-Host "The '$serviceName' service has been started." # write to the console and log file
    }
    else {
        Write-Host "The '$serviceName' service is already running."
    }
} catch {
    # Log any error messages
    Write-Host "Failed to ensure that '$serviceName' is running. Error: $_"
    exit 1
}

# Compress old logs
$zipPath = Join-Path -Path $folderPath -ChildPath "old_logs.zip"
$oldLogs = Get-ChildItem -Path $folderPath -Filter "*.txt" | Where-Object { $_.FullName -ne $logPath }
if ($oldLogs.Count -gt 0) {
    if (!(Test-Path -Path $zipPath)) {
        [System.IO.Compression.ZipFile]::CreateFromDirectory($folderPath, $zipPath, 'Optimal', $false)
    } else {
        $zipFile = [System.IO.Compression.ZipFile]::Open($zipPath, 'Update')
        foreach ($oldLog in $oldLogs) {
            $zipEntry = $zipFile.CreateEntryFromFile($oldLog.FullName, $oldLog.Name)
            $zipEntry.LastWriteTime = $oldLog.LastWriteTime
        }
        $zipFile.Dispose()
    }
    $oldLogs | Remove-Item -Force
}

# Stop transcript logging and close the log file
Stop-Transcript
