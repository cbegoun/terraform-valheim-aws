# Create Valheim directory
New-Item -Path "C:\valheim" -ItemType Directory -Force

# Copy the install_valheim.ps1 and watchdog.ps1 files into the directory
Copy-Item -Path "${path.module}\scripts\install_valheim.ps1" -Destination "C:\valheim\install_valheim.ps1"
Copy-Item -Path "${path.module}\scripts\watchdog.ps1" -Destination "C:\valheim\watchdog.ps1"

# --- Run Valheim install script now ---
powershell.exe -ExecutionPolicy Bypass -File "C:\valheim\install_valheim.ps1"

# --- Schedule watchdog on boot ---
schtasks /Create /TN "ValheimWatchdog" /TR "powershell.exe -ExecutionPolicy Bypass -File `"`"C:\valheim\watchdog.ps1`"`"" /SC ONSTART /RL HIGHEST /F
