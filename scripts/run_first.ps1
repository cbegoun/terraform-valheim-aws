# Define paths
$valheimDir = "C:\valheim"
$steamCmdDir = "$valheimDir\steamcmd"
$serverDir = "$valheimDir\server"

# Create directories for Valheim and SteamCMD
New-Item -ItemType Directory -Force -Path $steamCmdDir, $serverDir | Out-Null

# Download SteamCMD if it's not already installed
$steamCmdZip = "$steamCmdDir\steamcmd.zip"
if (-Not (Test-Path "$steamCmdDir\steamcmd.exe")) {
    Write-Host "Downloading SteamCMD..."
    Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile $steamCmdZip
    Expand-Archive -Path $steamCmdZip -DestinationPath $steamCmdDir -Force
}

# Install Valheim via SteamCMD
Write-Host "Installing Valheim server..."
Start-Process -NoNewWindow -Wait -FilePath "$steamCmdDir\steamcmd.exe" -ArgumentList @(
    "+login anonymous",
    "+force_install_dir $serverDir",
    "+app_update 896660 validate",
    "+quit"
)

# Create start script for Valheim server
$startScript = @'
@echo off
cd /d C:\valheim\server
start valheim_server.exe -nographics -batchmode -name "MyServer" -port 2456 -world "MyWorld" -password "password123" -public 1
'@

$startScriptPath = "$valheimDir\start_valheim.bat"
Set-Content -Path $startScriptPath -Value $startScript -Encoding ASCII

# Create watchdog.ps1 script
$watchdogScript = @'
# This is a placeholder script for the watchdog functionality
# Implement the logic for checking activity and restarting the server if necessary
Write-Host "Running Valheim Watchdog..."
'@

$watchdogScriptPath = "$valheimDir\watchdog.ps1"
Set-Content -Path $watchdogScriptPath -Value $watchdogScript -Encoding UTF8

# Schedule Valheim server to start on boot
Write-Host "Scheduling Valheim server to start on boot..."
$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -eq "ValheimServerStart" }
if (-not $taskExists) {
    schtasks /Create /TN "ValheimServerStart" /TR "C:\valheim\start_valheim.bat" /SC ONSTART /RL HIGHEST /F
} else {
    Write-Host "Valheim server start task already scheduled."
}

# Schedule Watchdog to run on boot
Write-Host "Scheduling Valheim Watchdog to run on boot..."
$watchdogTaskExists = Get-ScheduledTask | Where-Object { $_.TaskName -eq "ValheimWatchdog" }
if (-not $watchdogTaskExists) {
    schtasks /Create /TN "ValheimWatchdog" /TR "powershell.exe -ExecutionPolicy Bypass -File `"`"C:\valheim\watchdog.ps1`"`"" /SC ONSTART /RL HIGHEST /F
} else {
    Write-Host "Watchdog task already scheduled."
}

Write-Host "Valheim installation and configuration complete. The server and watchdog will start on reboot."
