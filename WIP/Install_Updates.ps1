# Specify the path to the CSV file containing host names
$csvPath = "C:\Working_Projects\Servers.csv"

# Import the CSV file and select the HostName column
$hostList = Import-Csv -Path $csvPath | Select-Object -ExpandProperty HostName

# Prompt for credentials manually
$credentials = Get-Credential -Message "Enter your credentials" -UserName "DOMAIN\Username"

# Define the scriptblock that will be executed on each host
$scriptblock = {
    param($hostname)

    Write-Host "Processing host: $hostname"

    # Run Windows Update
    Write-Host "Running Windows Update..."
    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    $result = $searcher.Search("IsInstalled=0")

    # Check if updates are available
    if ($result.Updates.Count -gt 0) {
        Write-Host "Updates found. Installing..."

        # Install updates
        $installer = $session.CreateUpdateInstaller()
        $installer.Updates = $result.Updates
        $installationResult = $installer.Install()

        # Check the installation result and print a report
        if ($installationResult.ResultCode -eq 2) {
            Write-Host "Updates installed successfully."
        }
        else {
            Write-Host "Updates failed to install."
            Write-Host "Result Code: $($installationResult.ResultCode)"
            Write-Host "Result Message: $($installationResult.ResultMessage)"
        }
    }
    else {
        Write-Host "No updates to install."
    }
}

# Iterate through each host in the list
foreach ($hostname in $hostList) {
    Write-Host "Connecting to host: $hostname"

    try {
        # Use PowerShell remoting to run the update scriptblock on the host
        Invoke-Command -ComputerName $hostname -ScriptBlock $scriptblock -ArgumentList $hostname -Credential $credentials -ErrorAction Stop -Verbose
    }
    catch {
        Write-Host "Failed to connect to host: $hostname"
        Write-Host "Error: $_"
    }

    Write-Host
}
