# Remove the PCname since it's no longer required.
# Instead, get the local machine's name
$PCname = $env:COMPUTERNAME

# Load the System.Windows.Forms assembly
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")>$null

# Set a flag to repeat the script
$Repeat = $True

# Loop while the flag is true
While ($Repeat)
{
    # Define a function to retrieve the memory usage of the local computer
    function Get-MemoryUsage ($ComputerName=$PCname){
        # Retrieve the operating system information from the local computer
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

    # Call the Get-MemoryUsage function
    Get-MemoryUsage

    # Instead of using a message box to prompt the user, we simply pause for 3 minutes (180 seconds)
    Start-Sleep -Seconds 180
}
