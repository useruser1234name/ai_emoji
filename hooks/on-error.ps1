# PostToolUseFailure: 도구 실패 시 당황 반응
# 단, 권한창이 떠있던 경우(=유저 거절)는 Stop 이 rejected 로 처리하므로 여기선 건너뜀
$base = Join-Path $env:USERPROFILE ".claude\mascot"
$flag = Join-Path $base "pending.flag"
[void][Console]::In.ReadToEnd()
if (Test-Path $flag) { return }   # 거절 경로 → error 로 표시하지 않음
& (Join-Path $base 'set-state.ps1') error
