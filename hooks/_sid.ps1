# 공용: stdin JSON 을 UTF-8 로 읽어 전역 $HookRaw / $HookJson / $Sid 세팅
$HookRaw = (New-Object System.IO.StreamReader([Console]::OpenStandardInput(), [System.Text.Encoding]::UTF8)).ReadToEnd()
$HookJson = $null
$Sid = 'default'
try {
    $HookJson = $HookRaw | ConvertFrom-Json
    if ($HookJson.session_id) { $Sid = [string]$HookJson.session_id }
} catch {}
$SidSafe = ($Sid -replace '[^A-Za-z0-9_-]','_')
if ([string]::IsNullOrWhiteSpace($SidSafe)) { $SidSafe = 'default' }
