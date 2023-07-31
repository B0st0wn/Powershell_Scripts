$driveLetters = 'U:', 'W:', 'P:', 'F:'

foreach ($drive in $driveLetters) {
    if (Test-Path $drive) {
        Remove-PSDrive -Name $drive.TrimEnd(':') -PSProvider 'FileSystem' -ErrorAction SilentlyContinue
    } else {
        Write-Output "Drive $drive does not exist"
    }
}
