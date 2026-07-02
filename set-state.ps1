# set-state.ps1 - 마스코트 상태 변경 (세션별)
param([string]$State = "idle", [string]$SessionId = "default")
$base = Join-Path $env:USERPROFILE ".claude\mascot"
if (-not (Test-Path $base)) { New-Item -ItemType Directory -Force $base | Out-Null }
$sid = ($SessionId -replace '[^A-Za-z0-9_-]','_')
if ([string]::IsNullOrWhiteSpace($sid)) { $sid = 'default' }
Set-Content -Path (Join-Path $base ("state-" + $sid + ".txt")) -Value ("$State`t" + (Get-Random)) -Encoding UTF8
