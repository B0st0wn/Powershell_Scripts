# Set the working directory to the DCU installation location
Set-Location "C:\Program Files\Dell\CommandUpdate"

# This command will set DCU to only look for BIOS, Hardware Firmware, and Software Drivers
$configureCommand = ".\dcu-cli.exe /configure ""-updatetype=bios,firmware,driver"""
# This command then suspends BitLocker and applies the updates
$applyUpdatesCommand = ".\dcu-cli.exe /applyUpdates -autoSuspendBitLocker=Enable"

# Execute the commands using cmd.exe to handle potential quoting issues
cmd.exe /c $configureCommand
cmd.exe /c $applyUpdatesCommand
