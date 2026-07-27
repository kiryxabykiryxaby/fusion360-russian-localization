# Install / restore Russian localization into Fusion 360 (Windows).
# One-click and universal: it targets the build Fusion ACTUALLY runs and re-applies
# the translation. Safe to run any number of times. Re-run after every Fusion update.
#
# How the active build is found (most reliable first):
#   1. FusionLauncher.exe.ini -> the "cmd = ...\production\<HASH>\Fusion360.exe" line.
#      This is Autodesk's own pointer to the build that launches - the ground truth.
#   2. Fallback: the build whose Fusion360.exe has the highest ProductVersion.
# We deliberately do NOT trust folder modification time: copying files into an old
# build bumps its timestamp and would make a stale build look "newest".

$ErrorActionPreference = 'Stop'

function Fail($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red; exit 1 }

$here  = Split-Path -Parent $MyInvocation.MyCommand.Path
$files = Join-Path $here 'files'
$prod  = Join-Path $env:LOCALAPPDATA 'Autodesk\webdeploy\production'

Write-Host ""
Write-Host "=========================================="
Write-Host " Fusion 360 Russian Localization Installer"
Write-Host "=========================================="
Write-Host ""

# --- Sanity checks -----------------------------------------------------------
if (-not (Test-Path (Join-Path $files 'ru-RU'))) {
  Fail "Translation files not found: $files`n        Run this from the repo root (the folder that contains 'files')."
}
if (-not (Test-Path $prod)) {
  Fail "Fusion 360 install not found: $prod`n        Install Fusion from https://www.autodesk.com/products/fusion-360 first."
}
if (Get-Process Fusion360 -ErrorAction SilentlyContinue) {
  Fail "Fusion 360 is running. Close it completely and re-run this installer."
}

# --- Find the ACTIVE build ---------------------------------------------------
$active = $null
$source = ''

# 1) Authoritative: the launcher's ini names the exact build it starts.
$ini = Get-ChildItem (Join-Path $prod '*\FusionLauncher.exe.ini') -ErrorAction SilentlyContinue |
       Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($ini) {
  $cmdLine = Get-Content $ini.FullName | Where-Object { $_ -match '^\s*cmd\s*=' } | Select-Object -First 1
  if ($cmdLine -match 'production[\\/]([0-9a-fA-F]{40})[\\/]Fusion360\.exe') {
    $cand = Join-Path $prod $matches[1]
    if (Test-Path (Join-Path $cand 'Fusion360.exe')) {
      $active = $cand
      $source = 'FusionLauncher.exe.ini'
    }
  }
}

# 2) Fallback: highest Fusion360.exe ProductVersion among real builds.
if (-not $active) {
  $active = Get-ChildItem $prod -Directory |
    Where-Object { (Test-Path (Join-Path $_.FullName 'Fusion360.exe')) -and (Test-Path (Join-Path $_.FullName 'StringTable')) } |
    Sort-Object { [version](Get-Item (Join-Path $_.FullName 'Fusion360.exe')).VersionInfo.ProductVersion } -Descending |
    Select-Object -First 1 -ExpandProperty FullName
  if ($active) { $source = 'highest Fusion360.exe version' }
}

if (-not $active) {
  Fail "Could not find an active Fusion build in:`n        $prod`n        Launch Fusion once so it finishes installing/updating, then re-run this."
}

if (-not (Test-Path (Join-Path $active 'StringTable'))) {
  Fail "Active build has no StringTable folder: $active"
}

$ver = (Get-Item (Join-Path $active 'Fusion360.exe')).VersionInfo.ProductVersion
Write-Host ("Active Fusion build: " + (Split-Path $active -Leaf))
Write-Host ("Version:             " + $ver)
Write-Host ("Detected via:        " + $source)
if (Test-Path (Join-Path $active 'StringTable\ru-RU')) {
  Write-Host "Status:              ru-RU already present - refreshing it."
} else {
  Write-Host "Status:              ru-RU not found in this build - installing it."
}
Write-Host ""

# --- Copy the three payloads (create parent paths if missing) ----------------
function Ensure-Dir($p) { if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null } }

Write-Host "[1/3] Copying ru-RU into StringTable..."
Copy-Item (Join-Path $files 'ru-RU') (Join-Path $active 'StringTable\ru-RU') -Recurse -Force

Write-Host "[2/3] Copying ru-html into NeuCAM Help..."
$helpDir = Join-Path $active 'NeuCAM\UI\NeuCAMUI\Resources\Help'
Ensure-Dir $helpDir
Copy-Item (Join-Path $files 'ru-html') (Join-Path $helpDir 'ru-html') -Recurse -Force

Write-Host "[3/3] Copying russian_ru.xml into Translations..."
$trDir = Join-Path $active 'Applications\CAM360\Data\Translations'
Ensure-Dir $trDir
Copy-Item (Join-Path $files 'russian_ru.xml') (Join-Path $trDir 'russian_ru.xml') -Force

# --- Verify ------------------------------------------------------------------
$ruCount = (Get-ChildItem (Join-Path $active 'StringTable\ru-RU') -Filter *.xml -ErrorAction SilentlyContinue).Count

Write-Host ""
Write-Host "=========================================="
if ($ruCount -ge 100) {
  Write-Host " Done. Russian installed - $ruCount UI files in place." -ForegroundColor Green
} else {
  Write-Host " [WARNING] Only $ruCount ru-RU files found - expected ~115." -ForegroundColor Yellow
  Write-Host " Something may have gone wrong; check the messages above."
}
Write-Host "=========================================="
Write-Host ""
Write-Host "Now launch Fusion 360 and go to:"
Write-Host "    Preferences (Ctrl+,) > General > User Language > Russian"
Write-Host "Then confirm the restart prompt."
Write-Host ""
