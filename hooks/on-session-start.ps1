# SessionStart: 이 세션 전용 마스코트 창을 띄움 (세션마다 하나)
$base = Join-Path $env:USERPROFILE ".claude\mascot"
. (Join-Path $PSScriptRoot '_sid.ps1')
Start-Process powershell -WindowStyle Hidden -ArgumentList `
    '-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $base 'mascot.ps1'),'-SessionId',$Sid
