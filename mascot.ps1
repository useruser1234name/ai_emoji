# mascot.ps1 - 클로드 코드 마스코트 (캐릭터/움짤 + 말풍선)
# state.txt = 상태(생각/코딩/완료 등)  |  config.json = 문구·이모지·크기 커스텀
# 이미지: images\<상태>.gif|png  또는  images\character.gif|png
# config.json 을 저장하면 즉시 반영됩니다. 사진/움짤 교체도 실시간 반영.

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$script:base      = Join-Path $env:USERPROFILE ".claude\mascot"
$script:stateFile = Join-Path $script:base "state.txt"
$script:imgDir    = Join-Path $script:base "images"
$script:cfgFile   = Join-Path $script:base "config.json"

# ── 중복 실행 방지 (창은 하나만) ─────────────────────────────
$script:mutex = New-Object System.Threading.Mutex($false, "ClaudeMascotSingleton_v1")
if (-not $script:mutex.WaitOne(0)) { exit }

# ── 기본값 ──────────────────────────────────────────────────
function Set-Defaults {
    $script:fps            = 12
    $script:charWidth      = 150
    $script:emojiSize      = 68
    $script:bubbleFont     = 15
    $script:bubbleMaxWidth = 250
    $script:emotionSize    = 34    # 감정 이모지 스티커 크기
    $script:messages = @{
        "idle"     = @("대기 중이야~ 💤", "부르면 언제든 와요 🙌")
        "thinking" = @("음... 어떻게 짤까 🤔", "생각 중이야~ 💭", "잠깐만, 궁리 중 🧠")
        "coding"   = @("코딩 중이야! 👨‍💻", "타닥타닥... ⌨️", "이 줄이 핵심이지 ✍️", "조금만 기다려줘~ 💻", "거의 다 됐어! 🔥")
        "waiting"  = @("잠깐! 확인이 필요해 🙋", "이거 허락해줄래? 🥺")
        "done"     = @("다 했어! 빨리 검토해줘! 🎉", "완성! 확인 부탁해 ✨", "짠~ 다 끝냈어! 🙌")
        "rejected" = @("(눈물 그렁) 너... 너 같은 게 내 맘도 모르고... 흑 😢", "왜 나한테 그래! 내 편이어야 되잖아... 흑흑", "거절이라니... 딱히 상처받은 거 아니거든! (훌쩍)")
    }
    $script:emojis = @{
        "idle"     = @("😌","🙄","😐")
        "thinking" = @("🧐","🤔","💭")
        "coding"   = @("😤","⌨️","💻","✍️")
        "waiting"  = @("😤","🙄","😠","💢")
        "done"     = @("😏","😤","💅","😌","✨")
        "rejected" = @("😭","😢","🥺","😞")
    }
    $script:nickname = "야"   # 대사 속 {name} 이 이 호칭으로 치환됨
}

# ── config.json 로 덮어쓰기 ─────────────────────────────────
function Load-Config {
    Set-Defaults
    if (-not (Test-Path $script:cfgFile)) { return }
    try {
        $cfg = Get-Content $script:cfgFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($cfg.fps)            { $script:fps            = [int]$cfg.fps }
        if ($cfg.charWidth)      { $script:charWidth      = [double]$cfg.charWidth }
        if ($cfg.emojiSize)      { $script:emojiSize      = [double]$cfg.emojiSize }
        if ($cfg.bubbleFontSize) { $script:bubbleFont     = [double]$cfg.bubbleFontSize }
        if ($cfg.bubbleMaxWidth) { $script:bubbleMaxWidth = [double]$cfg.bubbleMaxWidth }
        if ($cfg.emotionSize)    { $script:emotionSize    = [double]$cfg.emotionSize }
        if ($cfg.nickname)       { $script:nickname       = [string]$cfg.nickname }
        if ($cfg.messages) {
            foreach ($k in $cfg.messages.PSObject.Properties.Name) { $script:messages[$k] = @($cfg.messages.$k) }
        }
        if ($cfg.emojis) {
            foreach ($k in $cfg.emojis.PSObject.Properties.Name) { $script:emojis[$k] = @($cfg.emojis.$k) }
        }
    } catch { }
}
Load-Config

# ── 창 & 컨트롤 ─────────────────────────────────────────────
$window = New-Object System.Windows.Window
$window.WindowStyle        = 'None'
$window.AllowsTransparency = $true
$window.Background         = [System.Windows.Media.Brushes]::Transparent
$window.Topmost            = $true
$window.ShowInTaskbar      = $false
$window.ShowActivated      = $false
$window.ResizeMode         = 'NoResize'
$window.SizeToContent      = 'WidthAndHeight'

$root = New-Object System.Windows.Controls.StackPanel
$root.HorizontalAlignment = 'Center'

$bubble = New-Object System.Windows.Controls.Border
$bubble.CornerRadius = New-Object System.Windows.CornerRadius(16)
$bubble.Background    = [System.Windows.Media.Brushes]::White
$bubble.Padding      = New-Object System.Windows.Thickness(14,10,14,10)
$bubble.Margin       = New-Object System.Windows.Thickness(0,0,0,4)
$shadow = New-Object System.Windows.Media.Effects.DropShadowEffect
$shadow.BlurRadius = 14; $shadow.ShadowDepth = 2; $shadow.Opacity = 0.35
$bubble.Effect = $shadow

$script:msg = New-Object System.Windows.Controls.TextBlock
$script:msg.TextWrapping = 'Wrap'
$script:msg.FontFamily   = New-Object System.Windows.Media.FontFamily("Malgun Gothic, Segoe UI Emoji")
$script:msg.Foreground   = [System.Windows.Media.Brushes]::Black
$script:msg.Text         = "안녕! 준비됐어 😊"
$bubble.Child = $script:msg

# 캐릭터(사진/움짤) + 감정 이모지 스티커를 겹쳐 배치
$charGrid = New-Object System.Windows.Controls.Grid

$script:charText = New-Object System.Windows.Controls.TextBlock
$script:charText.HorizontalAlignment = 'Center'
$script:charText.VerticalAlignment   = 'Center'
$script:charText.FontFamily          = New-Object System.Windows.Media.FontFamily("Segoe UI Emoji")
$script:charText.Text                = $script:emojis["idle"]

$script:charImg = New-Object System.Windows.Controls.Image
$script:charImg.Stretch    = 'Uniform'
$script:charImg.Visibility = 'Collapsed'

# 감정 이모지 스티커 (우측 상단, 별도 말풍선)
$script:emoBubble = New-Object System.Windows.Controls.Border
$script:emoBubble.CornerRadius       = New-Object System.Windows.CornerRadius(999)
$script:emoBubble.Background          = [System.Windows.Media.Brushes]::White
$script:emoBubble.Padding             = New-Object System.Windows.Thickness(7,2,7,3)
$script:emoBubble.HorizontalAlignment = 'Right'
$script:emoBubble.VerticalAlignment   = 'Top'
$script:emoBubble.Margin              = New-Object System.Windows.Thickness(0,2,2,0)
$script:emoBubble.Visibility          = 'Collapsed'
$es = New-Object System.Windows.Media.Effects.DropShadowEffect
$es.BlurRadius = 8; $es.ShadowDepth = 1; $es.Opacity = 0.35
$script:emoBubble.Effect = $es

$script:emoText = New-Object System.Windows.Controls.TextBlock
$script:emoText.FontFamily = New-Object System.Windows.Media.FontFamily("Segoe UI Emoji")
$script:emoText.Text       = $script:emojis["idle"]
$script:emoBubble.Child    = $script:emoText

$charGrid.Children.Add($script:charImg)   | Out-Null
$charGrid.Children.Add($script:charText)  | Out-Null
$charGrid.Children.Add($script:emoBubble) | Out-Null

$root.AddChild($bubble); $root.AddChild($charGrid)
$window.Content = $root

# 크기/폰트 적용 (config 반영)
function Apply-Appearance {
    $script:msg.FontSize        = $script:bubbleFont
    $bubble.MaxWidth            = $script:bubbleMaxWidth
    $script:charText.FontSize   = $script:emojiSize
    $script:emoText.FontSize    = $script:emotionSize
    $script:charImg.Width       = $script:charWidth
    $script:animTimer.Interval  = [TimeSpan]::FromMilliseconds([int](1000 / [Math]::Max(1,$script:fps)))
}

# ── 위치: 우측 하단 ─────────────────────────────────────────
function Set-Position {
    $wa = [System.Windows.SystemParameters]::WorkArea
    $window.Left = $wa.Right  - $window.ActualWidth  - 20
    $window.Top  = $wa.Bottom - $window.ActualHeight - 10
}
$window.Add_Loaded({ Set-Position })
$window.Add_SizeChanged({ Set-Position })
$window.Add_MouseLeftButtonDown({ $window.DragMove() })
$window.Add_MouseRightButtonUp({ $window.Close() })

# ── GIF 애니메이션 ──────────────────────────────────────────
$script:frames = $null
$script:frameIdx = 0
$script:animTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:animTimer.Interval = [TimeSpan]::FromMilliseconds([int](1000 / [Math]::Max(1,$script:fps)))
$script:animTimer.Add_Tick({
    if ($script:frames -and $script:frames.Count -gt 0) {
        $script:charImg.Source = $script:frames[$script:frameIdx]
        $script:frameIdx = ($script:frameIdx + 1) % $script:frames.Count
    }
})
Apply-Appearance

function Show-Media([string]$path) {
    $script:animTimer.Stop(); $script:frames = $null; $script:frameIdx = 0
    try {
        if ($path.ToLower().EndsWith(".gif")) {
            $dec = [System.Windows.Media.Imaging.BitmapDecoder]::Create((New-Object System.Uri($path)), 'None', 'Default')
            $script:frames = $dec.Frames
            $script:charImg.Source = $script:frames[0]
            if ($script:frames.Count -gt 1) { $script:animTimer.Start() }
        } else {
            $bmp = New-Object System.Windows.Media.Imaging.BitmapImage
            $bmp.BeginInit(); $bmp.CacheOption='OnLoad'; $bmp.UriSource=New-Object System.Uri($path); $bmp.EndInit()
            $script:charImg.Source = $bmp
        }
    } catch { return $false }
    $script:charImg.Visibility  = 'Visible'
    $script:charText.Visibility = 'Collapsed'
    return $true
}

# ── 상태별 갱신 ─────────────────────────────────────────────
function Update-Mascot([string]$state) {
    if (-not $script:messages.ContainsKey($state)) { $state = "idle" }
    $script:curState = $state
    $pool = $script:messages[$state]
    if ($pool -and $pool.Count -gt 0) {
        $line = $pool[(Get-Random -Maximum $pool.Count)]
        $script:msg.Text = $line.Replace('{name}', $script:nickname)
    }
    $epool = $script:emojis[$state]
    $emo = if ($epool -and $epool.Count -gt 0) { $epool[(Get-Random -Maximum $epool.Count)] } else { "🙂" }
    $script:emoText.Text = $emo

    $cands = @(
        (Join-Path $script:imgDir "$state.gif"),  (Join-Path $script:imgDir "$state.png"),
        (Join-Path $script:imgDir "$state.jpg"),   (Join-Path $script:imgDir "$state.jpeg"),
        (Join-Path $script:imgDir "character.gif"),(Join-Path $script:imgDir "character.png"),
        (Join-Path $script:imgDir "character.jpg"),(Join-Path $script:imgDir "character.jpeg")
    )
    $found = $cands | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($found -and (Show-Media $found)) { $script:emoBubble.Visibility = 'Visible'; return }

    # 사진 없으면: 큰 이모지를 캐릭터로 (감정 스티커는 숨김)
    $script:animTimer.Stop(); $script:frames = $null
    $script:emoBubble.Visibility = 'Collapsed'
    $script:charText.Text       = $emo
    $script:charText.Visibility = 'Visible'
    $script:charImg.Visibility  = 'Collapsed'
}

# ── 폴링: 상태 변화 + config 실시간 리로드 ──────────────────
$script:last = ""
$script:curState = "idle"
$script:cfgStamp = if (Test-Path $script:cfgFile) { (Get-Item $script:cfgFile).LastWriteTimeUtc } else { [datetime]::MinValue }
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(400)
$timer.Add_Tick({
    # config.json 이 바뀌면 즉시 반영
    if (Test-Path $script:cfgFile) {
        $st = (Get-Item $script:cfgFile).LastWriteTimeUtc
        if ($st -ne $script:cfgStamp) {
            $script:cfgStamp = $st
            Load-Config; Apply-Appearance; Update-Mascot $script:curState
        }
    }
    # 상태 변화 반영
    $raw = if (Test-Path $script:stateFile) { (Get-Content $script:stateFile -Raw -Encoding UTF8) } else { "idle" }
    if ($raw -ne $script:last) {
        $script:last = $raw
        Update-Mascot (($raw -split "`t")[0].Trim())
    }
})
$timer.Start()

$window.Show()
[System.Windows.Threading.Dispatcher]::Run()
