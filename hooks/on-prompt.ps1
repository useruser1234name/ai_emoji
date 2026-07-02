# UserPromptSubmit: pending flag 정리 + 당신 메시지 키워드로 반응 (세션별)
$base = Join-Path $env:USERPROFILE ".claude\mascot"
. (Join-Path $PSScriptRoot '_sid.ps1')

$text = ''
if ($HookJson) { $text = [string]$HookJson.prompt }

$flag = Join-Path $base ("pending-" + $SidSafe + ".flag")
if (Test-Path $flag) { Remove-Item $flag -Force -ErrorAction SilentlyContinue }

$state = 'thinking'
if     ($text -match '고마워|고맙|감사|수고했|잘했|최고|땡큐|thank') { $state = 'thanks' }
elseif ($text -match '짜증|화나|빡|답답|아 ?진짜|하아|하…|왜 ?안 ?돼|왜 이래|미치겠|개같|열받') { $state = 'annoyed' }

& (Join-Path $base 'set-state.ps1') $state $Sid
