# Prompt user for inputs
$folderName = Read-Host "Enter the folder name (e.g., MyFolder)"
$iconName = Read-Host "Enter the name of the icon file (e.g., icon.ico)"
$link = Read-Host "Enter the URL for the shortcut"
$shortcutName = Read-Host "Enter the name for the shortcut (e.g., MyShortcut.lnk)"

# Create the full path to the directory
$fullFolderPath = Join-Path -Path "C:\Program Files (x86)\" -ChildPath $folderName

# Check if directory exists, if not, create it
if (-not (Test-Path $fullFolderPath)) {
    New-Item -Path $fullFolderPath -ItemType Directory
}

# Copy the icon file to the directory
Copy-Item -Path $iconName -Destination $fullFolderPath -ErrorAction SilentlyContinue

# Create or replace the desktop shortcut
$shell = New-Object -ComObject "WScript.Shell"
$shortcut = $shell.CreateShortcut((Join-Path $shell.SpecialFolders.Item("AllUsersDesktop") $shortcutName))

# Set the icon location
$shortcut.IconLocation = Join-Path -Path $fullFolderPath -ChildPath $iconName

$shortcut.TargetPath = $link
$shortcut.Save()
