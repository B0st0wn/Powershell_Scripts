<#Editor: Visual Studio Code
Script Name: No_Sleep.ps1
Author: Paul Hanlon
Date: 12/4/2021
Description: 
  This Beats sleep by pressing scroll lock. 
  This method allows for use of the system and prevents sleep. 
  Along with sets a timer and tracks all scroll lock trigger events into console.
#>

param($sleep = 180) # sets a default value of 180 seconds for the $sleep parameter, which determines how long the script will wait before toggling the Scroll Lock key again
$announcementInterval = 10 # sets the interval for announcing elapsed time to every 10 loops
Clear-Host # clears the PowerShell console

# creates a new COM object to send keystrokes
$WShell = New-Object -com "Wscript.Shell"

# gets the current date and time in a specific format and assigns it to the $date variable
$date = Get-Date -Format "dddd MM/dd hh:mmtt"

# declares the $stopwatch variable, which will be used to measure the elapsed time of the script
$stopwatch

# starts the stopwatch and assigns it to the $stopwatch variable
# writes an error message if the stopwatch cannot be started
try {
    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
}
catch {
    Write-Host "Couldn't start the stopwatch."
}

# writes a message to the console in green text
Write-Host "Executing No Sleep routine." -fore Green

# writes the start time to the console in green text
Write-Host "Start time:"$date -fore Green

# initializes the $index variable, which will be used to count the number of loops
$index = 0

# creates an infinite loop
while ( $true ) {

    # sends the Scroll Lock keystroke to the system
    $WShell.sendkeys("{SCROLLLOCK}")

    # waits for 200 milliseconds
    Start-Sleep -Milliseconds 200

    # sends the Scroll Lock keystroke again to toggle it off
    $WShell.sendkeys("{SCROLLLOCK}")

    # writes "Toggled" to the console in red text
    Write-Host "Toggled" -fore Red

    # waits for the number of seconds specified by the $sleep parameter
    Start-Sleep -Seconds $sleep

    # checks if the stopwatch is running and if the number of loops is a multiple of the announcement interval
    if ( $stopwatch.IsRunning -and (++$index % $announcementInterval) -eq 0 ) {

        # writes the elapsed time to the console in white text
        Write-Host "Elapsed time:"  -fore White $stopwatch.Elapsed.ToString('dd\.hh\:mm\:ss')
    }
}
