# Define the list of commands to run
$commands = @(
    "sfc /scannow"
    "Dism /Online /Cleanup-Image /ScanHealth",
    "Dism /Online /Cleanup-Image /CheckHealth",
    "Dism /Online /Cleanup-Image /RestoreHealth"
)

# Loop through the commands and run them one by one
foreach ($command in $commands) {
    Write-Host "Running command: $command"
    Invoke-Expression $command
}
