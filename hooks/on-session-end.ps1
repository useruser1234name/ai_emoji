# SessionEnd: 이 세션의 마스코트 창을 닫음
$base = Join-Path $env:USERPROFILE ".claude\mascot"
. (Join-Path $PSScriptRoot '_sid.ps1')
& (Join-Path $base 'set-state.ps1') quit $Sid
