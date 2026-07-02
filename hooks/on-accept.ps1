# PostToolUse (도구 실행됨 = 수락): pending flag 해제 + coding (세션별)
$base = Join-Path $env:USERPROFILE ".claude\mascot"
. (Join-Path $PSScriptRoot '_sid.ps1')
$flag = Join-Path $base ("pending-" + $SidSafe + ".flag")
if (Test-Path $flag) { Remove-Item $flag -Force -ErrorAction SilentlyContinue }
& (Join-Path $base 'set-state.ps1') coding $Sid
