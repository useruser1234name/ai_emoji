# set-state.ps1 - hooks가 호출해서 마스코트 상태를 바꿉니다.
param([string]$State = "idle")

$base = Join-Path $env:USERPROFILE ".claude\mascot"
if (-not (Test-Path $base)) { New-Item -ItemType Directory -Force $base | Out-Null }

# nonce를 붙여서 같은 상태여도 매번 말풍선이 새로 바뀌게 함
$nonce = Get-Random
Set-Content -Path (Join-Path $base "state.txt") -Value "$State`t$nonce" -Encoding UTF8
