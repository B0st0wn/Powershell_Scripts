# Registry paths to disable the insecure protocols for both Client and Server
$protocols = 'SSL 2.0', 'SSL 3.0', 'TLS 1.0', 'TLS 1.1'
$locations = 'Server', 'Client'
$registryPathTemplate = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{0}\{1}"

# Loop through each protocol and disable them
foreach($protocol in $protocols){
    foreach($location in $locations){
        $registryPath = $registryPathTemplate -f $protocol, $location
        if(!(Test-Path -Path $registryPath)){
            # Create registry structure if it doesn't exist
            New-Item -Path $registryPath -Force | Out-Null
        }
        
        New-ItemProperty -Path $registryPath -Name "Enabled" -Value 0 -PropertyType "DWord" -Force | Out-Null
    }
}

# Output an exit code of 69
exit 69
