Get admin credentials
$domaincredential = Get-Credential -Message "Enter your Domain\Admin credentials"

Import CSV file
$computers = Import-Csv -Path "C:\path\to\your\file.csv"

Rename computers
foreach ($computer in $computers) {

    # Check if new name is valid
    if ([string]::IsNullOrEmpty($computer.NewName)) {
        Write-Error "Invalid new name for computer $computer.OldName. Skipping."
        continue
    }

    # Rename computer
    try {
        Rename-Computer -ComputerName $computer.OldName -NewName $computer.NewName -DomainCredential $domaincredential -Force -Restart
        Write-Information "Successfully renamed $computer.OldName to $computer.NewName."
    }
    catch {
        Write-Error "Failed to rename $computer.OldName. Error: $_"
    }
}