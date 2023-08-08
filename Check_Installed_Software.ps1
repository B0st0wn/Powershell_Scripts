# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Define a function named Software
function Software {
    # Get a list of installed software from the HKLM registry key
    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" 
    
    # Output a blank line for formatting
    Write-Output " "
    
    # Loop through each installed software and output the display name, version, and uninstall string
    foreach ($Software in $InstalledSoftware) { 
        Write-Output $Software.GetValue('DisplayName')
        Write-Output $software.GetValue('DisplayVersion')
        Write-Output $software.GetValue('UninstallString')
        Write-Output " " 
    }
    
    # Get a list of installed software from the HKCU registry key
    $InstalledSoftware = Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    
    # Output a header for user-installed software
    Write-Output "User Installed:"
    Write-Output " "
    
    # Loop through each installed software and output the display name, version, and uninstall string
    foreach ($obj in $InstalledSoftware) { 
        Write-Output $obj.GetValue('DisplayName')
        Write-Output $obj.GetValue('DisplayVersion')
        Write-Output $obj.GetValue('UninstallString')
        Write-Output " " 
    }
}

# Ask user for save location using Save File Dialog
$saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
$saveFileDialog.Filter = "Text files (*.txt)|*.txt"
$saveFileDialog.Title = "Save the software log file"
$saveFileDialog.ShowDialog() | Out-Null
$filePath = $saveFileDialog.FileName

# Ensure that a path was provided
if (-not [string]::IsNullOrWhiteSpace($filePath)) {
    # Call the Software function and output the result to a text file at the selected location
    Software | Out-File -FilePath $filePath -Force
    Write-Host "Finished saving software log to $filePath."
}
else {
    Write-Warning "No save location selected. Aborting save operation."
}
