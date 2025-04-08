# Watchdog Script for Valheim Server

# Define the directory where the server is located
$valheimDirectory = "C:\valheim"
$serverExecutable = "C:\valheim\valheim_server.exe"
$timeout = 1200  # Timeout in seconds (20 minutes)
$lastActivityFile = "C:\valheim\last_activity.txt"

# Function to check for activity (e.g., by checking the last connection time)
function Check-Activity {
    if (Test-Path $lastActivityFile) {
        $lastActivityTime = Get-Content $lastActivityFile | ConvertTo-DateTime
        $currentTime = Get-Date

        # If more than 20 minutes have passed since the last activity, shut down the server
        if ($currentTime - $lastActivityTime -gt (New-TimeSpan -Seconds $timeout)) {
            Write-Host "No activity detected for 20 minutes. Shutting down the server."
            Stop-Process -Name "valheim_server" -Force
        } else {
            Write-Host "Activity detected. Server is running."
        }
    } else {
        Write-Host "No last activity file found. Assuming the server is newly started."
    }
}

# Main loop for the watchdog script
while ($true) {
    # Check activity every minute
    Check-Activity
    Start-Sleep -Seconds 60
}
