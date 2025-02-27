$steamcmdPath = "C:\steamcmd"
$serverPath = "C:\valheim"
$steamAppId = "896660"

if (!(Test-Path $steamcmdPath)) {
    New-Item -ItemType Directory -Path $steamcmdPath
    Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile "$steamcmdPath\steamcmd.zip"
    Expand-Archive -Path "$steamcmdPath\steamcmd.zip" -DestinationPath $steamcmdPath
}

& "$steamcmdPath\steamcmd.exe" +login anonymous +force_install_dir $serverPath +app_update $steamAppId validate +quit

# Firewall rule to allow Valheim traffic
New-NetFirewallRule -DisplayName "Valheim UDP Ports" -Direction Inbound -Protocol UDP -LocalPort 2456-2458 -Action Allow

# Create a startup script
$serverName = "${server_name}"
$serverWorld = "${server_world}"
$serverPassword = "${server_password}"

$startupScript = @"
Start-Process -NoNewWindow -FilePath "$serverPath\valheim_server.exe" -ArgumentList "-nographics -batchmode -name $serverName -port 2456 -world $serverWorld -password $serverPassword"
"@
$startupScript | Set-Content -Path "C:\valheim\start_valheim.ps1"

# Schedule startup script to run on boot
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\valheim\start_valheim.ps1"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName "StartValheimServer" -Action $taskAction -Trigger $taskTrigger -RunLevel Highest -User "SYSTEM"
