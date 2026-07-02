# PreToolUse: 실행하려는 도구/명령을 보고 어울리는 상태를 고름 (세션별)
$base = Join-Path $env:USERPROFILE ".claude\mascot"
. (Join-Path $PSScriptRoot '_sid.ps1')

$tool = ''; $cmd = ''
if ($HookJson) {
    $tool = [string]$HookJson.tool_name
    if ($HookJson.tool_input) { $cmd = [string]$HookJson.tool_input.command }
}

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
if ($state) { & (Join-Path $base 'set-state.ps1') $state $Sid }
