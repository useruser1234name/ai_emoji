# PostToolUse (tool actually ran = accepted): clear pending flag + back to coding
$base = Join-Path $env:USERPROFILE ".claude\mascot"
$flag = Join-Path $base "pending.flag"
if (Test-Path $flag) { Remove-Item $flag -Force -ErrorAction SilentlyContinue }
& (Join-Path $base "set-state.ps1") coding
