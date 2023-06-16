# Specify the path to the CSV file containing server names
$csvPath = "C:\Working_Projects\Servers.csv"

# Import the CSV file and select the ServerName column
$serverList = Import-Csv -Path $csvPath | Select-Object -ExpandProperty ServerName

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
            
            # Run Windows Update
            $session = New-Object -ComObject Microsoft.Update.Session -ErrorAction Stop
            $searcher = $session.CreateUpdateSearcher()
            $result = $searcher.Search("IsInstalled=0")
            
            # Check if updates are available
            if ($result.Updates.Count -gt 0) {
                Write-Host "Updates found. Installing..."
                
                # Download updates
                $downloader = $session.CreateUpdateDownloader()
                $downloader.Updates = $result.Updates
                $downloader.Download()
                
                # Install updates
                $installer = $session.CreateUpdateInstaller()
                $installer.Updates = $result.Updates
                $installResult = $installer.Install()
                
                # Check installation result
                if ($installResult.ResultCode -eq 2) {
                    Write-Host "Installation successful."
                } else {
                    Write-Host "Installation failed with error code $($installResult.ResultCode)."
                }
            } else {
                Write-Host "No updates available."
            }
        } else {
            Write-Host "Unsupported Windows version: $osVersion"
        }
    } catch {
        Write-Host "Failed to connect to server: $server"
    }
    
    Write-Host
}
