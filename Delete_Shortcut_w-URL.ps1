
# Prompt user for the name of the shortcut they want to delete
$shortcutName = Read-Host "Enter the name of the shortcut you want to delete (e.g., MyShortcut.lnk)"

# Create the full path to the shortcut on the desktop
$shortcutPath = Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath $shortcutName

# Check if shortcut exists, if so, delete it
if (Test-Path $shortcutPath) {
    Remove-Item -Path $shortcutPath -Force
    Write-Host "Shortcut deleted successfully."
} else {
    Write-Host "Shortcut not found on the desktop."
}
