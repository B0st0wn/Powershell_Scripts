#Map Drives
#Remove Old Mappings
Start-Sleep -Seconds 60
try {
    net use U: /delete >$null 2>&1
}
catch {
    Write-Output "No existing network drive at U:"
}

try {
    net use W: /delete >$null 2>&1
}
catch {
    Write-Output "No existing network drive at W:"
}

# Get the current user's identity
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

# Get the user's group membership and convert it to lowercase
$groupMembership = $currentUser.Groups | ForEach-Object { $_.Translate([System.Security.Principal.NTAccount]).Value.ToLower() }

# Output the group membership for diagnosis
Write-Output "Group membership: $groupMembership"

# Define the groups that should map specific network drives with their network paths and corresponding drive letters
$groupDriveMappings = @{
    "HANLONHOUSE\HAN-FILES_Windows_Packages" = @{ #Group Name
        DriveLetter = "U"
        NetworkPath = "\\han-dc2-file\Windows Packages"
    }
    "HANLONHOUSE\HAN-FILES_Working_Space" = @{ #Group Name
        DriveLetter = "W"
        NetworkPath = "\\han-dc2-file\Working_Projects"
    }
    # Add more group-drive mappings as needed
}

# Check if the user belongs to any of the groups that have drive mappings
foreach ($group in $groupDriveMappings.Keys) {
    # Convert the group name to lowercase for comparison
    if ($groupMembership -contains $group.ToLower()) {
        $driveLetter = $groupDriveMappings[$group].DriveLetter
        $networkPath = $groupDriveMappings[$group].NetworkPath

        # Map the network drive
        try {
            New-PSDrive -Name $driveLetter -Root $networkPath -Persist -PSProvider FileSystem
            Write-Output "Mapped network drive ${driveLetter}: to ${networkPath}"
        }
        catch {
            Write-Output "Error mapping network drive ${driveLetter}: to ${networkPath}: $_"
        }
    }
    else {
        Write-Output "User is not a member of $group"
    }
}
