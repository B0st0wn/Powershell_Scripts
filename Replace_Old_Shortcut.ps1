#Define the old and new links
$oldLink = "old link"
$newLink = "new link"

#Get the user's desktop folder path
$userDesktop = [Environment]::GetFolderPath("Desktop")

#Find all shortcut files in the user's desktop folder
$shortcuts = Get-ChildItem -Path $userDesktop -Filter "*.lnk"

#Loop through each shortcut file
foreach($shortcut in $shortcuts) {

    #Get the target path of the shortcut file
    $targetPath = $shortcut.TargetPath

    #Check if the target path of the shortcut file matches the old link
    if($targetPath -eq $oldLink) {

        #Remove the shortcut file from the user's desktop folder
        Remove-Item $shortcut -Force -ErrorAction SilentlyContinue

        #Create a new shortcut file in the user's desktop folder with the new link
        New-Item -ItemType Shortcut -Path $userDesktop -Name "New Shortcut" -Target $newLink
    }
}