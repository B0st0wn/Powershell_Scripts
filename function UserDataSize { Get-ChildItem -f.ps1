function Get-UserDataSize {
    # Create an array to store the user data sizes
    $userData = @()

    # Get a list of all directories under C:\Users, and iterate through each one
    Get-ChildItem -Force 'C:\Users' -ErrorAction SilentlyContinue | Where-Object { $_ -is [io.directoryinfo] } | ForEach-Object {
        # Calculate the total size of the current user's directory
        $totalSize = Get-ChildItem -Recurse -File -Force $_.FullName -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum

        # Create a custom object to store the user's directory name and size
        $userData += [PSCustomObject]@{
            'User' = $_.Name
            'Size (GB)' = [math]::Round($totalSize / 1GB, 2)
        }
    }

    # Display the user sizes
    $userData | Format-Table -AutoSize

    # Calculate and display the total size of all user profiles
    $sum = ($userData | Measure-Object 'Size (GB)' -Sum).Sum
    Write-Output "Total size of profiles: $($sum) GB"
}

# Call the Get-UserDataSize function to execute it
Get-UserDataSize
