# SessionStart: 이 세션 전용 마스코트 창을 띄움 (세션마다 하나, 페르소나 배정)
$base = Join-Path $env:USERPROFILE ".claude\mascot"
. (Join-Path $PSScriptRoot '_sid.ps1')

# 페르소나 선택: (1) $env:MASCOT_PERSONA 수동 지정 우선  (2) 없으면 personas/ 에서 랜덤
$personasDir = Join-Path $base "personas"
$chosen = ""
if ($env:MASCOT_PERSONA) {
    $c = $env:MASCOT_PERSONA -replace '[^A-Za-z0-9_-]',''
    if ($c -and (Test-Path (Join-Path $personasDir $c))) { $chosen = $c }
}
if (-not $chosen -and (Test-Path $personasDir)) {
    $list = @(Get-ChildItem $personasDir -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
    if ($list.Count -gt 0) { $chosen = $list[(Get-Random -Maximum $list.Count)] }
}

Start-Process powershell -WindowStyle Hidden -ArgumentList `
    '-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $base 'mascot.ps1'),'-SessionId',$Sid,'-Persona',$chosen
