# UserPromptSubmit: pending flag 정리 + 당신 메시지 키워드로 반응
$base = Join-Path $env:USERPROFILE ".claude\mascot"
$flag = Join-Path $base "pending.flag"
if (Test-Path $flag) { Remove-Item $flag -Force -ErrorAction SilentlyContinue }

$raw = (New-Object System.IO.StreamReader([Console]::OpenStandardInput(), [System.Text.Encoding]::UTF8)).ReadToEnd()
$text = ''
try { $j = $raw | ConvertFrom-Json; $text = [string]$j.prompt } catch {}

$state = 'thinking'
if     ($text -match '고마워|고맙|감사|수고했|잘했|최고|땡큐|thank') { $state = 'thanks' }
elseif ($text -match '짜증|화나|빡|답답|아 ?진짜|하아|하…|왜 ?안 ?돼|왜 이래|미치겠|개같|열받') { $state = 'annoyed' }

& (Join-Path $base 'set-state.ps1') $state
