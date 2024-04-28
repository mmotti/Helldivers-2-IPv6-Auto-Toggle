param (
    [Parameter(Mandatory=$false)]
    [switch]$firstRun
)

Function Set-IPv6 {
    param (
        [Parameter(Mandatory=$true)]
        $networkAdapter,

        [Parameter(Mandatory=$true)]
        [bool]
        $Enable
    )

    # This function will enable or disable IPv6 depending on the state of the $Enable bool
    # Admin access is required to be able to change this setting
    try {
        $networkAdapter | Set-NetAdapterBinding -ComponentID ms_tcpip6 -Enabled $Enable -ErrorAction Stop
        if ($Enable) {
            Write-Host "IPv6 successfully enabled for $($networkAdapter.Name)" -ForegroundColor Green
        } else {
            Write-Host "IPv6 successfully disabled for $($networkAdapter.Name)" -ForegroundColor Green
        }
    }
    catch {
        throw 'An error occurred whilst attempting to change the state of IPv6.'
        Exit 1
    }
}

Function New-Shortcut {
    param (
        [Parameter(Mandatory=$false)]
        $icon
    )

    # This doesn't necessarily need to be within a function however it makes the code a little neater.

    try {
        Write-Host 'Creating desktop shortcut...'

        # Construct destination (desktop)
        $scriptPath = $PSCommandPath
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path $desktopPath 'HELLDIVERS™ 2 (IPv4).lnk'
        # Start constructing the shortcut
        $shell = New-Object -ComObject("WScript.Shell")
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "$([Environment]::GetFolderPath('System'))\WindowsPowerShell\v1.0\powershell.exe"
        $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`""
        if ($icon) {
            $shortcut.IconLocation = $icon
        }
        $shortcut.WorkingDirectory = Split-Path $scriptPath
        $shortcut.Save()

        # Set the shortcut to run as Admin
        # https://stackoverflow.com/questions/28997799/how-to-create-a-run-as-administrator-shortcut-using-powershell
        $bytes = [System.IO.File]::ReadAllBytes($shortcutPath)
        $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
        [System.IO.File]::WriteAllBytes($shortcutPath, $bytes)

        Write-Host "Desktop shortcut created: '$shortcutPath'" -ForegroundColor Green
    }
    catch {
        # If we get here somehow we won't end the script as it's not critical
        # just makes life easier
        Write-Host 'Something went wrong when trying to create a desktop shortcut' -ForegroundColor Red
    }
}

# Process options
$processPath = "steam://rungameid/553850"
$processTimeout = 15
$processMonitored = 'helldivers2'

# Check for Administrator
# and exit if necessary
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::
        GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host 'Administrator privileges are required to change the state of IPv6.' -ForegroundColor Red
    Write-Host 'Please re-run the script as Administrator' -ForegroundColor Red
    Start-Sleep -Seconds 5
    Exit 1
}

# Get the active network adapter
Write-Host 'Searching for an active Network Adapter...'
$activeNetworkAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}

# Check that we receive a single active Network Adapter and not an array of > 1
if ($activeNetworkAdapter -and $activeNetworkAdapter -isnot [array]) {
   
    Write-Host "Network Adapter found: $($activeNetworkAdapter.Name)" -ForegroundColor Yellow
    
    # Check IPv6 is enabled on the network adapter
    if (($activeNetworkAdapter | Get-NetAdapterBinding -ComponentID ms_tcpip6).Enabled) {

        # Disable IPv6
        Set-IPv6 -networkAdapter $activeNetworkAdapter -Enable $false

        # Launch the game
        Write-Host "Launching $processMonitored..."
        Start-Process $processPath
        
       # Keep checking until we detect that the game has launched
       # with a timeout
       $elapsedTime = 0
        
        Do { 
            $processObject = Get-Process $processMonitored -ErrorAction SilentlyContinue
            if ($elapsedTime -eq $processTimeout) {
                Write-Host 'Something went wrong whilst attempting to launch the process' -ForegroundColor Red
                Set-IPv6 -networkAdapter $activeNetworkAdapter -Enable $true
                Start-Sleep -Seconds 5
                Exit 1
            }

            Start-Sleep -Seconds 1
            $elapsedTime++
        }
        While ($null -eq $processObject)

        Write-Host "Process launched" -ForegroundColor Green

        # We'll create a desktop shortcut for the script on first run as it's not particularly 
        # straight forward for end-users to create shortcuts for PowerShell scripts especially if they require
        # admin rights.

        # Calling it here allows us to only create a shortcut if the script is relevant to the user (IPv6 is enabled)
        # and means that we can grab the icon directly from the game process.

        if ($firstRun) {
            New-Shortcut -icon $processObject.Path
        }

        # Wait for the game to exit
        Write-Host "Waiting for the process to exit..."
        $processObject | Wait-Process

        # Game has exited
        Write-Host "The $processMonitored process has exited" -ForegroundColor Yellow

        Write-Host 'Cleaning up...'

        # Enable IPv6
        Set-IPv6 -networkAdapter $activeNetworkAdapter -Enable $true

        Start-Sleep -Seconds 5
    }
    else {
        Write-Host "IPv6 is NOT enabled for $($activeNetworkAdapter.Name)"
        Write-Host 'No action is necessary' -ForegroundColor Green
        Start-Sleep -Seconds 5
        Exit 0
    }
}
# There were either no active network adapters or >1
else {
    Write-Host "$($activeNetworkAdapter.Count) 'active' Network Adapters were found." -ForegroundColor Red
    Write-Host 'This script is unable to function unless there is only 1 active Network Adapter.' -ForegroundColor Red
    # Show the active network adapters and exit
    $activeNetworkAdapter
    Start-Sleep -Seconds 5
    Exit 1
}