# PreToolUse: 실행하려는 도구/명령을 보고 어울리는 상태를 고름
$base = Join-Path $env:USERPROFILE ".claude\mascot"
$raw = (New-Object System.IO.StreamReader([Console]::OpenStandardInput(), [System.Text.Encoding]::UTF8)).ReadToEnd()
$tool = ''; $cmd = ''
try {
    $j = $raw | ConvertFrom-Json
    $tool = [string]$j.tool_name
    if ($j.tool_input) { $cmd = [string]$j.tool_input.command }
} catch {}

$state = ''
if ($tool -eq 'Bash' -or $tool -eq 'PowerShell') {
    if     ($cmd -match 'git\s+commit')                                                     { $state = 'committing' }
    elseif ($cmd -match 'git\s+push')                                                       { $state = 'pushing' }
    elseif ($cmd -match 'deploy|vercel|netlify|kubectl\s+apply|fly\s+deploy|railway\s+up|serverless') { $state = 'deploy' }
    elseif ($cmd -match 'docker')                                                           { $state = 'docker' }
    elseif ($cmd -match '(npm|pnpm)\s+(i|install|add|ci)\b|yarn\s+(add|install)|pip3?\s+install|bundle\s+install|cargo\s+(add|install)|apt(-get)?\s+install|brew\s+install|go\s+get') { $state = 'install' }
    elseif ($cmd -match 'eslint|lint|prettier|ruff|flake8|black\s|gofmt|clippy|stylelint')  { $state = 'lint' }
    elseif ($cmd -match '(npm|yarn|pnpm)\s+(run\s+)?test|pytest|jest|vitest|go\s+test|cargo\s+test|dotnet\s+test') { $state = 'testing' }
    else                                                                                    { $state = 'coding' }
} elseif ('Write','Edit','MultiEdit','NotebookEdit' -contains $tool) {
    $state = 'coding'
}
if ($state) { & (Join-Path $base 'set-state.ps1') $state }
