function UserDataSize {
    # Get a list of all directories under C:\Users, and iterate through each one
    Get-ChildItem -force 'C:\Users'-ErrorAction SilentlyContinue | Where-Object { $_ -is [io.directoryinfo] } | ForEach-Object {
        # Initialize a variable to store the total size of the current user's directory
        $len = 0
        # Recursively search for all files within the current user's directory, and iterate through each one
        Get-ChildItem -recurse -force $_.fullname -ErrorAction SilentlyContinue | ForEach-Object { $len += $_.length }
        # Display the current user's directory name and size in GB
        $_.fullname, '{0:N2} GB' -f ($len / 1Gb)
        # Add the current user's directory size to the total sum
        $sum = $sum + $len
    }
    # Display the total size of all user profiles in GB
    “Total size of profiles”, '{0:N2} GB' -f ($sum / 1Gb)
}

# Call the UserDataSize function to execute it
UserDataSize
