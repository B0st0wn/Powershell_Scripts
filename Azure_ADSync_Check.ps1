$serviceName = "ADSync"

# Change to network share path
$folderPath = "\\NAS\Systems\Azure\Azure_Logs"
if (!(Test-Path -Path $folderPath)){
    New-Item -ItemType Directory -Force -Path $folderPath
}

$logFileName = "{0}_Check_{1:HHmmss}.log" -f $serviceName, (Get-Date)
$logPath = Join-Path -Path $folderPath -ChildPath $logFileName

$null = New-Item -Path $logPath -ItemType File -Force

Start-Transcript -Path $logPath -Force

try {
    $service = Get-Service -Name $serviceName -ErrorAction Stop
    if ($service.Status -eq 'Stopped') {
        Start-Service -Name $serviceName -ErrorAction Stop
        Write-Host "The '$serviceName' service has been started."
    }
    else {
        Write-Host "The '$serviceName' service is already running."
    }
} catch {
    Write-Host "Failed to ensure that '$serviceName' is running. Error: $_"
    exit 1
}

$zipPath = Join-Path -Path $folderPath -ChildPath "old_logs.7z"
$oldLogs = Get-ChildItem -Path $folderPath -Filter "*.log" | Where-Object { $_.FullName -ne $logPath }

# Add files to 7z archive using 7-zip
if ($oldLogs.Count -gt 0) {
    foreach ($log in $oldLogs) {
        $7zipResult = Start-Process -FilePath "C:\Program Files\7-Zip\7z.exe" -ArgumentList "a -t7z -mx9 `"$zipPath`" `"$($log.FullName)`"" -Wait -PassThru
        if ($7zipResult.ExitCode -ne 0) {
            Write-Host "7-zip encountered an error: exit code $($7zipResult.ExitCode)"
        } else {
            Remove-Item -Path $log.FullName -Force
        }
    }
}

Stop-Transcript
