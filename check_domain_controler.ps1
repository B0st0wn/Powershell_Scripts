$desiredLogonServer = "\\HAN-DC2-FILE"
$regPath = 'HKCU:\Volatile Environment'
$logonServerValue = 'LogonServer'

$currentLogonServer = Get-ItemPropertyValue -Path $regPath -Name $logonServerValue

if ($currentLogonServer -ne $desiredLogonServer) {
    Set-ItemProperty -Path $regPath -Name $logonServerValue -Value $desiredLogonServer
    Write-Host "Logon server has been updated. Please log off and log back on for the changes to take effect."
}
else {
    Write-Host "The logon server is already set to the desired value."
}

