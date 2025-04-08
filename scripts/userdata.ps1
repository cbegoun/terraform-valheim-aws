# Ensure we are running as Administrator
if (-not (Test-Path "C:\valheim")) {
    # Create Valheim directory
    New-Item -Path "C:\valheim" -ItemType Directory -Force
}

# Install Valheim if not already installed
$steamCmdDir = "C:\valheim\steamcmd"
$serverDir = "C:\valheim\server"

# Create directories if they don't exist
if (-not (Test-Path $steamCmdDir)) {
    New-Item -ItemType Directory -Force -Path $steamCmdDir
}
if (-not (Test-Path $serverDir)) {
    New-Item -ItemType Directory -Force -Path $serverDir
}

# Download SteamCMD if it's not already there
$steamCmdZip = "$steamCmdDir\steamcmd.zip"
if (-not (Test-Path "$steamCmdDir\steamcmd.exe")) {
    Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile $steamCmdZip
    Expand-Archive -Path $steamCmdZip -DestinationPath $steamCmdDir -Force
}

# Install Valheim via SteamCMD if it's not installed
if (-not (Test-Path "$serverDir\valheim_server.exe")) {
    Start-Process -NoNewWindow -Wait -FilePath "$steamCmdDir\steamcmd.exe" -ArgumentList @(
        "+login anonymous",
        "+force_install_dir $serverDir",
        "+app_update 896660 validate",
        "+quit"
    )
}

# Create start script for Valheim server
$startScript = @'
@echo off
cd /d C:\valheim\server
start valheim_server.exe -nographics -batchmode -name "MyValheimServer" -port 2456 -world "MyWorld" -password "MyPassword" -public 1
'@

$startScriptPath = "C:\valheim\start_valheim.bat"
Set-Content -Path $startScriptPath -Value $startScript -Encoding ASCII

# Start the Valheim server
Start-Process -FilePath $startScriptPath -WindowStyle Hidden

# Schedule the Watchdog script to run on boot
$watchdogScriptPath = "C:\valheim\watchdog.ps1"
$watchdogTask = Get-ScheduledTask | Where-Object { $_.TaskName -eq "ValheimWatchdog" }
if (-not $watchdogTask) {
    schtasks /Create /TN "ValheimWatchdog" /TR "powershell.exe -ExecutionPolicy Bypass -File `"`"C:\valheim\watchdog.ps1`"`"" /SC ONSTART /RL HIGHEST /F
}

Write-Host "Valheim Server installation and startup complete."
