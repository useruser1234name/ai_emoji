# ai_emoji installer - copies mascot files to ~/.claude/mascot
# Usage:  powershell -ExecutionPolicy Bypass -File install.ps1
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$dest = Join-Path $env:USERPROFILE ".claude\mascot"

Write-Host "Installing ai_emoji mascot to: $dest"
New-Item -ItemType Directory -Force (Join-Path $dest "hooks")  | Out-Null
New-Item -ItemType Directory -Force (Join-Path $dest "images") | Out-Null

# Copy scripts (always overwrite)
Copy-Item (Join-Path $repo "mascot.ps1")    $dest -Force
Copy-Item (Join-Path $repo "set-state.ps1") $dest -Force
Copy-Item (Join-Path $repo "hooks\*.ps1")   (Join-Path $dest "hooks") -Force
if (Test-Path (Join-Path $repo "images\README.txt")) {
    Copy-Item (Join-Path $repo "images\README.txt") (Join-Path $dest "images") -Force
}

# config.json: keep existing (don't clobber user customization)
$cfgDest = Join-Path $dest "config.json"
if (-not (Test-Path $cfgDest)) {
    Copy-Item (Join-Path $repo "config.json") $cfgDest -Force
    Write-Host "config.json installed (default Kurisu theme)."
} else {
    Write-Host "config.json already exists - kept your version (not overwritten)."
}

# Ensure PowerShell 5.1 reads Korean correctly: re-save .ps1 as UTF-8 with BOM
$bom = New-Object System.Text.UTF8Encoding($true)
Get-ChildItem $dest -Recurse -Filter *.ps1 | ForEach-Object {
    $t = [System.IO.File]::ReadAllText($_.FullName, [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText($_.FullName, $t, $bom)
}

Write-Host ""
Write-Host "Done. Next steps:"
Write-Host "  1) Merge the 'hooks' block from settings.hooks.example.json into ~/.claude/settings.json"
Write-Host "  2) Drop your own images into $dest\images  (see images/README.txt)"
Write-Host "  3) Restart Claude Code."
Write-Host ""
Write-Host "To preview now without restarting, run:"
Write-Host "  Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','$dest\mascot.ps1'"
