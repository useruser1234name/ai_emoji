# make-persona.ps1 - 새 페르소나(말투/캐릭터 프리셋) 폴더를 만들어줍니다.
# 사용:  powershell -ExecutionPolicy Bypass -File make-persona.ps1 -Name taiga
param([Parameter(Mandatory=$true)][string]$Name)

$base = Join-Path $env:USERPROFILE ".claude\mascot"
$safe = $Name -replace '[^A-Za-z0-9_-]',''
if ([string]::IsNullOrWhiteSpace($safe)) { Write-Host "이름이 올바르지 않습니다 (영문/숫자/_/-)"; exit 1 }

$dir = Join-Path $base ("personas\" + $safe)
New-Item -ItemType Directory -Force (Join-Path $dir "images") | Out-Null

$cfg = Join-Path $dir "config.json"
if (-not (Test-Path $cfg)) {
    $src = Join-Path $base "config.json"
    if (Test-Path $src) { Copy-Item $src $cfg -Force }
}

Write-Host ("페르소나 생성됨: " + $dir)
Write-Host "  1) config.json 에서 messages / emojis / nickname 을 이 캐릭터 말투로 수정"
Write-Host "  2) images\<상태>\ 폴더에 사진/움짤을 넣기 (예: images\done\, images\rejected\)"
Write-Host ("  3) 사용: 터미널에서  `$env:MASCOT_PERSONA='" + $safe + "'  설정 후 claude 실행, 또는 그냥 두면 랜덤 후보에 포함")
