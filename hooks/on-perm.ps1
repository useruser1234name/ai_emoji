# Notification / PermissionRequest: 권한창 표시 기록 + waiting (세션별)
$base = Join-Path $env:USERPROFILE ".claude\mascot"
. (Join-Path $PSScriptRoot '_sid.ps1')
Set-Content -Path (Join-Path $base ("pending-" + $SidSafe + ".flag")) -Value "1" -ErrorAction SilentlyContinue
& (Join-Path $base 'set-state.ps1') waiting $Sid
