# Prompt the user to enter a computer name or IP address
$PCname = Read-Host "Please enter a computer name or IP"
# Load the System.Windows.Forms assembly
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")>$null
# Set a flag to repeat the script
$Repeat = $True
# Loop while the flag is true
While ($Repeat)
{
    # Define a function to retrieve the memory usage of a specified computer
    function Get-MemoryUsage ($ComputerName=$PCname){
        # Test if the specified computer is online and responding to ping
        if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
            # Retrieve the operating system information from the specified computer
            $ComputerSystem = Get-WmiObject -ComputerName $ComputerName -Class Win32_operatingsystem -Property CSName, TotalVisibleMemorySize, FreePhysicalMemory
            # Extract the computer name, free memory, and total memory information from the retrieved object
            $MachineName = $ComputerSystem.CSName
            $FreePhysicalMemory = ($ComputerSystem.FreePhysicalMemory) / (1mb)
            $TotalVisibleMemorySize = ($ComputerSystem.TotalVisibleMemorySize) / (1mb)
            $TotalVisibleMemorySizeR = "{0:N2}" -f $TotalVisibleMemorySize
            $TotalFreeMemPerc = ($FreePhysicalMemory/$TotalVisibleMemorySize)*100
            $TotalFreeMemPercR = "{0:N2}" -f $TotalFreeMemPerc

            # Display the computer name, total memory, and percentage of free memory
            "Name: $MachineName"
            "RAM: $TotalVisibleMemorySizeR GB"
            "Free Physical Memory: $TotalFreeMemPercR %"
        }
    }

    # Call the Get-MemoryUsage function
    Get-MemoryUsage
    # Prompt the user to run the script again
    $Answer = [Windows.Forms.MessageBox]::Show("Run Again?", "Repeat",
        [Windows.Forms.MessageBoxButtons]::YESNO,
        [Windows.Forms.MessageBoxIcon]::Information)
    # If the user clicks "No", set the flag to false to exit the loop
    If ($Answer -eq "No")
    {
        $Repeat = $False
    }
}
