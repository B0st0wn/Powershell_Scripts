try {
    $WshShell = New-Object -ComObject WScript.Shell
    $checkOSArch = $WshShell.RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\PROCESSOR_ARCHITECTURE")
}
catch {
    $regkey = "HKEY_LOCAL_MACHINE\SOFTWARE\AdventNet\DesktopCentral\DCAgent\"
}

if (!$regkey) {
    if ($checkOSArch -eq "x86") {
        $regkey = "HKEY_LOCAL_MACHINE\SOFTWARE\AdventNet\DesktopCentral\DCAgent\"
    }
    else {
        $regkey = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\AdventNet\DesktopCentral\DCAgent\"
    }
}

try {
    $agentVersion = $WshShell.RegRead($regkey + "DCAgentVersion")
}
catch {
    # Do nothing, just continue with the script
}

if ($agentVersion) {
    Start-Process "msiexec.exe" -ArgumentList "/x{6AD2231F-FF48-4D59-AC26-405AFAE23DB7} /q" -Wait
}
