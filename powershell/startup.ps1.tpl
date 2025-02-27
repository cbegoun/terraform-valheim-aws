# Define Paths
$steamcmdPath = "C:\steamcmd"
$serverPath = "C:\valheim"
$steamAppId = "896660"

# Ensure directories exist
if (!(Test-Path $steamcmdPath)) { New-Item -ItemType Directory -Path $steamcmdPath }
if (!(Test-Path $serverPath)) { New-Item -ItemType Directory -Path $serverPath }

# Install SteamCMD if not installed
if (!(Test-Path "$steamcmdPath\steamcmd.exe")) {
    Write-Host "Downloading SteamCMD..."
    Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile "$steamcmdPath\steamcmd.zip"
    Expand-Archive -Path "$steamcmdPath\steamcmd.zip" -DestinationPath $steamcmdPath
    Remove-Item "$steamcmdPath\steamcmd.zip"
}

# Install/Update Valheim Dedicated Server
Write-Host "Installing or updating Valheim Dedicated Server..."
& "$steamcmdPath\steamcmd.exe" +login anonymous +force_install_dir $serverPath +app_update $steamAppId validate +quit

# Ensure Required Dependencies are Installed
Write-Host "Checking and installing required dependencies..."
$dependencies = @("VC_redist.x64.exe") # Add more if necessary

foreach ($dep in $dependencies) {
    if (!(Test-Path "$serverPath\$dep")) {
        Write-Host "Downloading and installing $dep..."
        Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -OutFile "$serverPath\$dep"
        Start-Process -FilePath "$serverPath\$dep" -ArgumentList "/install /quiet /norestart" -Wait
    }
}

# Open firewall ports for Valheim
Write-Host "Configuring firewall rules..."
New-NetFirewallRule -DisplayName "Valheim UDP Ports" -Direction Inbound -Protocol UDP -LocalPort 2456-2458 -Action Allow

# Create Valheim Server Startup Script
Write-Host "Creating server startup script..."
$serverName = "$${server_name}"
$serverWorld = "$${server_world}"
$serverPassword = "$${server_password}"

$startupScript = @"
Start-Process -NoNewWindow -FilePath "$serverPath\valheim_server.exe" -ArgumentList "-nographics -batchmode -name $serverName -port 2456 -world $serverWorld -password $serverPassword"
"@
$startupScript | Set-Content -Path "$serverPath\start_valheim.ps1"

# Register Scheduled Task for Auto-Start
Write-Host "Registering scheduled task..."
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$serverPath\start_valheim.ps1`""
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "StartValheimServer" -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings $taskSettings

Write-Host "Setup complete. Rebooting to apply changes..."
Restart-Computer -Force
