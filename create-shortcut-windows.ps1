# Creates a Desktop shortcut that runs install-windows.bat with one double-click.
# Run this once. After every Fusion update, just double-click the Desktop shortcut
# to restore Russian - no need to find this repo again.

$ErrorActionPreference = 'Stop'

$here   = Split-Path -Parent $MyInvocation.MyCommand.Path
$target = Join-Path $here 'install-windows.bat'

if (-not (Test-Path $target)) {
  Write-Host "[ERROR] install-windows.bat not found next to this script:" -ForegroundColor Red
  Write-Host "        $target"
  exit 1
}

# Shortcut label "Вернуть русский в Fusion", built from Unicode code points so it
# survives regardless of how this .ps1 file itself is encoded on the user's system.
$codes = 0x0412,0x0435,0x0440,0x043D,0x0443,0x0442,0x044C,0x0020,
         0x0440,0x0443,0x0441,0x0441,0x043A,0x0438,0x0439,0x0020,0x0432,0x0020
$name  = ( -join ($codes | ForEach-Object { [char]$_ }) ) + 'Fusion'

$desktop = [Environment]::GetFolderPath('Desktop')
$lnkPath = Join-Path $desktop ($name + '.lnk')

$shell    = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($lnkPath)
$shortcut.TargetPath       = $target
$shortcut.WorkingDirectory = $here
$shortcut.IconLocation     = "$env:SystemRoot\System32\shell32.dll,44"
$shortcut.Description       = 'Restore Russian localization in Fusion 360'
$shortcut.Save()

Write-Host ""
Write-Host "[OK] Desktop shortcut created:" -ForegroundColor Green
Write-Host "     $lnkPath"
Write-Host ""
Write-Host "After each Fusion update, double-click that shortcut to restore Russian."
