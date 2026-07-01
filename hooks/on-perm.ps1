# Notification / PermissionRequest: mark that a permission prompt is up + set waiting
$base = Join-Path $env:USERPROFILE ".claude\mascot"
Set-Content -Path (Join-Path $base "pending.flag") -Value "1" -ErrorAction SilentlyContinue
& (Join-Path $base "set-state.ps1") waiting
