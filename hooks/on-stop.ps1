# Stop: 권한창이 미해결(flag 존재)이면 = 거절 → rejected, 아니면 done (세션별)
$base = Join-Path $env:USERPROFILE ".claude\mascot"
. (Join-Path $PSScriptRoot '_sid.ps1')
$flag = Join-Path $base ("pending-" + $SidSafe + ".flag")
if (Test-Path $flag) {
    Remove-Item $flag -Force -ErrorAction SilentlyContinue
    & (Join-Path $base 'set-state.ps1') rejected $Sid
} else {
    & (Join-Path $base 'set-state.ps1') done $Sid
}
