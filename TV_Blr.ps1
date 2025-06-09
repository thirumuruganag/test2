# Run as Administrator

# Variables
$tvFolder = "C:\TV"
$tvHostUrl = "https://download.teamviewer.com/download/TeamViewer_Host_Setup.exe"
$tvInstaller = "$tvFolder\TeamViewer_Host_Setup.exe"
$assignCmd = '"C:\Program Files\TeamViewer\TeamViewer.exe" assignment --id 0001CoABChBVDDZQ-zsR7p_J8XGnk4EVEigIACAAAgAJAG9gD7X9Rv-YOHn1Svqr1vwRZmJLN9j8s21qedujAJxrGkCg3TxKoOStDAkp0D3WnZVbDvdSfhzWc7jZ1maDT7FWZLjrKKQ7beOBr_ffzRMy4KU9pp9_-p-W7aW9g6RyPi99IAEQpuvHyAc="'

# Step 1: Create folder
if (-Not (Test-Path -Path $tvFolder)) {
    New-Item -ItemType Directory -Path $tvFolder -Force
}

# Step 2: Download TeamViewer Host
Write-Host "Downloading TeamViewer Host..."
Invoke-WebRequest -Uri $tvHostUrl -OutFile $tvInstaller

# Step 3: Install TeamViewer Host
if (Test-Path -Path $tvInstaller) {
    Write-Host "Installing TeamViewer Host..."
    Start-Process -FilePath $tvInstaller -ArgumentList "/S" -Wait -NoNewWindow

    # Step 4: Wait 20 seconds
    Start-Sleep -Seconds 20

    # Step 5: Run TeamViewer assignment via CMD
    Write-Host "Assigning TeamViewer Host to company account..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $assignCmd" -WindowStyle Hidden -Wait

    Write-Host "TeamViewer assignment complete."
} else {
    Write-Host "Download failed. Please check the URL or your internet connection." -ForegroundColor Red
}
