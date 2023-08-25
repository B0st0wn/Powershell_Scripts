$RemotelyPath = "C:\Program Files\Remotely\"

if (Test-Path $RemotelyPath) {
    Start-Process "$RemotelyPath\Remotely_Installer.exe" -ArgumentList "-uninstall -quiet"
}
else {
    exit 69
}
exit 69
