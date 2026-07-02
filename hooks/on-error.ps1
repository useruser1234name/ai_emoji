# PostToolUseFailure: 도구 실패 시 당황 반응 (세션별)
# 단, 권한창이 떠있던 경우(=유저 거절)는 Stop 이 rejected 로 처리하므로 건너뜀
$base = Join-Path $env:USERPROFILE ".claude\mascot"
. (Join-Path $PSScriptRoot '_sid.ps1')
$flag = Join-Path $base ("pending-" + $SidSafe + ".flag")
if (Test-Path $flag) { return }
& (Join-Path $base 'set-state.ps1') error $Sid
