# User-editable fields
$folderName = "FOLDER_NAME"
$iconName = "NEW_ICON.ico" # Comment this line if no icon is needed
$link = "https://www.somewhere.com/"
$shortcutName = "SHORTCUT_NAME.lnk"
$useCustomIcon = $true # Change to $false if no icon is needed

# Create the full path to the new directory
$fullFolderPath = Join-Path -Path "C:\Program Files (x86)\" -ChildPath $folderName

# Create the new directory
try {
    New-Item -Path $fullFolderPath -ItemType Directory -ErrorAction Stop
}
catch {
    Write-Host "Failed to create directory $fullFolderPath. Error: $_"
    exit
}

# Copy the icon file to the new directory, if applicable
if ($useCustomIcon) {
    try {
        Copy-Item -Path $iconName -Destination $fullFolderPath -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to copy icon file to $fullFolderPath. Error: $_"
        exit
    }
}

# Create the desktop shortcut
$shell = New-Object -ComObject "WScript.Shell"
$shortcut = $shell.CreateShortcut((Join-Path $shell.SpecialFolders.Item("AllUsersDesktop") $shortcutName))

# Set the icon location, if applicable
if ($useCustomIcon) {
    $shortcut.IconLocation = Join-Path -Path $fullFolderPath -ChildPath $iconName
}

$shortcut.TargetPath = $link
$shortcut.Save()
