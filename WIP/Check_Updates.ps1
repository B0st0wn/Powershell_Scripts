# Specify the path to the CSV file containing server names
$csvPath = "C:\Working_Projects\Servers.csv"
$outFile = "C:\Working_Projects\UpdateReport.csv" 

# Import the CSV file and select the ServerName column
$serverList = Import-Csv -Path $csvPath | Select-Object -ExpandProperty ServerName
 
# Define the scriptblock that will be executed on each server
$scriptblock = {
    param($server)

    # Run Windows Update
    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    $result = $searcher.Search("IsInstalled=0")

    # Check if updates are available
    if ($result.Updates.Count -gt 0) {
        # Display update information
        foreach ($update in $result.Updates) {
            # Determine if the update is optional
            $isOptional = if ($update.BrowseOnly) {"Yes"} else {"No"}

            # Create a custom PowerShell object for the update
            $updateObj = New-Object -TypeName PSObject -Property @{
                Server = $server
                UpdateTitle = $update.Title
                IsOptional = $isOptional
                UpdateID = $update.Identity.UpdateID
            }

            # Output the object so it can be collected by the calling script
            $updateObj
        }
    }
}

# Create an empty array to hold the update data
$updateData = @()

# Iterate through each server in the list
foreach ($server in $serverList) {
    Write-Host "Processing server: $server"
    
    try {
        # Get the Windows version of the server
        $osVersion = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $server).Version
        $majorVersion = [int]$osVersion.Split(".")[0]
        
        # Check if the Windows version is supported (between 6 and 10 inclusive)
        if ($majorVersion -ge 6 -and $majorVersion -le 10) {
            Write-Host "Windows version: $osVersion"
            
            # Use PowerShell remoting to run the update check scriptblock on the server and collect the results
            $serverUpdates = Invoke-Command -ComputerName $server -ArgumentList $server -ScriptBlock $scriptblock -ErrorAction Stop

            # Add the server's updates to the update data array
            $updateData += $serverUpdates
        } else {
            Write-Host "Unsupported Windows version: $osVersion"
        }
    } catch {
        Write-Host "Failed to connect to server: $server"
    }
    
    Write-Host
}

# Write the update data to a CSV file
$updateData | Select-Object Server, UpdateTitle, IsOptional, UpdateID, PSComputerName | Export-Csv -Path $outFile -NoTypeInformation
