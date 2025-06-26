# === CONFIGURATION ===
$userProfile = "$env:USERPROFILE"
$chromeDbPath = "$userProfile\AppData\Local\Google\Chrome\User Data\Default\History"
$outputFile = "C:\db.txt"
$sqlitePath = "$env:TEMP\sqlite3.exe"

# === DOWNLOAD SQLITE3 IF NEEDED ===
if (-not (Test-Path $sqlitePath)) {
    Write-Host "🔽 Downloading sqlite3..."
    Invoke-WebRequest -Uri "https://www.sqlite.org/2024/sqlite-tools-win-x64-3450200.zip" -OutFile "$env:TEMP\sqlite.zip"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$env:TEMP\sqlite.zip", "$env:TEMP\sqlite")
    $found = Get-ChildItem "$env:TEMP\sqlite" -Recurse -Filter sqlite3.exe | Select-Object -First 1
    if ($found) {
        Copy-Item $found.FullName $sqlitePath -Force
        Write-Host "✅ sqlite3.exe ready"
    } else {
        Write-Host "❌ Failed to extract sqlite3.exe"
        exit
    }
    Remove-Item "$env:TEMP\sqlite.zip"
}

# === EXPORT CHROME HISTORY ===
if (-not (Get-Process -Name chrome -ErrorAction SilentlyContinue)) {
    if (Test-Path $chromeDbPath) {
        Write-Host "📤 Exporting Chrome history to C:\db.txt..."
        & $sqlitePath "`"$chromeDbPath`"" `
        "SELECT datetime(last_visit_time/1000000-11644473600,'unixepoch') AS VisitTime, url, title FROM urls ORDER BY last_visit_time DESC;" `
        | Out-File -Encoding UTF8 $outputFile
        Write-Host "✅ History exported to: $outputFile"
    } else {
        Write-Host "❌ Chrome history database not found."
    }
} else {
    Write-Host "⚠️ Please close Google Chrome before exporting history."
}
