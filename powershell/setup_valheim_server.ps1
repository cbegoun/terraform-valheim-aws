# Define paths and parameters
$valheimInstallPath = "C:\valheim"
$serverExe = "$valheimInstallPath\valheim_server.exe"
$taskName = "StartValheimServer"
$batchFile = "$valheimInstallPath\start_valheim.bat"
$vcRedistUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vcRedistInstaller = "$env:TEMP\vc_redist.x64.exe"
$logFile = "$valheimInstallPath\setup_log.txt"

# Function to log messages
function Log-Message {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFile
}

Log-Message "Starting Valheim server setup..."

# Ensure the Valheim directory exists
if (-Not (Test-Path $valheimInstallPath)) {
    Log-Message "Creating Valheim server directory..."
    New-Item -ItemType Directory -Path $valheimInstallPath -Force
}

# Check if Valheim server executable exists
if (-Not (Test-Path $serverExe)) {
    Log-Message "ERROR: Valheim server executable not found in $valheimInstallPath. Exiting..."
    exit 1
}

# Check if Visual C++ Redistributable is installed
$vcRedistInstalled = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'Microsoft Visual C++ 20% Redistributable (x64)%'" | Select-Object -ExpandProperty Name
if (-Not $vcRedistInstalled) {
    Log-Message "Microsoft Visual C++ Redistributable not found. Downloading and installing..."
    Invoke-WebRequest -Uri $vcRedistUrl -OutFile $vcRedistInstaller
    Start-Process -FilePath $vcRedistInstaller -ArgumentList "/quiet /norestart" -Wait
    Log-Message "Visual C++ Redistributable installed."
} else {
    Log-Message "Visual C++ Redistributable is already installed."
}

# Create the Valheim startup batch file
Log-Message "Creating batch file to start Valheim server..."
@"
@echo off
cd /d "$valheimInstallPath"
"$serverExe" -nographics -batchmode -name "MyServer" -port 2456 -world "MyWorld" -password "password"
"@ | Out-File -Encoding utf8 -FilePath $batchFile -Force

# Ensure the task does not already exist
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Log-Message "Removing existing Task Scheduler entry..."
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Create the Task Scheduler task
Log-Message "Creating Task Scheduler task..."
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$batchFile`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings

Register-ScheduledTask -TaskName $taskName -InputObject $task

Log-Message "Task Scheduler task created successfully. Valheim server will start on system boot."

# Run the task immediately for testing
Log-Message "Starting Valheim server now for verification..."
Start-ScheduledTask -TaskName $taskName

Log-Message "Setup complete. Check logs for errors if the server does not start."
