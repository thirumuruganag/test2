# === CONFIGURATION ===
$userProfileName = "vijay.kumar"
$baseProfilePath = "C:\Users\$userProfileName"
$exportRoot = "C:\BrowserHistoryExport"
$subFolder = "$exportRoot\HistoryFiles"
$zipOutput = "$exportRoot\kdckwkww4772jsdmm746n4mu4n.zip"
$password = "Your@SecurePassword#123"
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
$sqlitePath = "$exportRoot\sqlite3.exe"

# === OUTPUT FILES ===
$outputEdge = "$exportRoot\edge_history.txt"
$outputChrome = "$exportRoot\chrome_history.txt"
$outputFirefox = "$exportRoot\firefox_history.txt"

# === CREATE FOLDERS ===
if (-not (Test-Path $exportRoot)) { New-Item $exportRoot -ItemType Directory | Out-Null }
if (-not (Test-Path $subFolder)) { New-Item $subFolder -ItemType Directory | Out-Null }

# === DOWNLOAD SQLITE3 IF NOT EXISTS ===
if (-not (Test-Path $sqlitePath)) {
    $sqliteZip = "$exportRoot\sqlite.zip"
    Invoke-WebRequest -Uri "https://www.sqlite.org/2024/sqlite-tools-win-x64-3450200.zip" -OutFile $sqliteZip
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($sqliteZip, $exportRoot)
    $sqliteExe = Get-ChildItem $exportRoot -Recurse -Filter "sqlite3.exe" | Select-Object -First 1
    if ($sqliteExe) { Move-Item $sqliteExe.FullName $sqlitePath -Force }
    Remove-Item $sqliteZip
}

# === FUNCTION TO EXPORT HISTORY ===
function Export-History {
    param ([string]$DbPath, [string]$Query, [string]$OutputFile, [string]$Browser)
    if (Test-Path $DbPath) {
        & $sqlitePath "`"$DbPath`"" "$Query" | Out-File -Encoding utf8 $OutputFile
        Write-Host "✅ $Browser history exported."
    } else {
        Write-Host "⚠️ $Browser DB not found."
    }
}

# === EXPORT BROWSER HISTORIES ===
if (-not (Get-Process -Name msedge -ErrorAction SilentlyContinue)) {
    $edgeDb = "$baseProfilePath\AppData\Local\Microsoft\Edge\User Data\Default\History"
    $edgeQuery = "SELECT datetime(last_visit_time/1000000-11644473600,'unixepoch') as VisitTime, url, title FROM urls ORDER BY last_visit_time DESC;"
    Export-History $edgeDb $edgeQuery $outputEdge "Edge"
}

if (-not (Get-Process -Name chrome -ErrorAction SilentlyContinue)) {
    $chromeDb = "$baseProfilePath\AppData\Local\Google\Chrome\User Data\Default\History"
    $chromeQuery = "SELECT datetime(last_visit_time/1000000-11644473600,'unixepoch') as VisitTime, url, title FROM urls ORDER BY last_visit_time DESC;"
    Export-History $chromeDb $chromeQuery $outputChrome "Chrome"
}

if (-not (Get-Process -Name firefox -ErrorAction SilentlyContinue)) {
    $ffProfileRoot = "$baseProfilePath\AppData\Roaming\Mozilla\Firefox\Profiles"
    $ffProfile = Get-ChildItem $ffProfileRoot -Directory | Where-Object { $_.Name -like "*.default-release" } | Select-Object -First 1
    if ($ffProfile) {
        $firefoxDb = "$($ffProfile.FullName)\places.sqlite"
        $firefoxQuery = "SELECT datetime(visit_date/1000000,'unixepoch') as VisitTime, url FROM moz_places, moz_historyvisits WHERE moz_places.id = moz_historyvisits.place_id ORDER BY visit_date DESC;"
        Export-History $firefoxDb $firefoxQuery $outputFirefox "Firefox"
    }
}

# === MOVE FILES TO FOLDER ===
Get-ChildItem -Path $exportRoot -Filter *.txt | Move-Item -Destination $subFolder -Force

# === CREATE PASSWORD-PROTECTED ZIP ===
if (Test-Path $zipOutput) { Remove-Item $zipOutput -Force }
& "$sevenZipPath" a -tzip "`"$zipOutput`"" "`"$subFolder\*`"" -p"$password" -mem=AES256
Write-Host "✅ ZIP file created at $zipOutput"
