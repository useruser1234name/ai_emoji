# import-photos.ps1 - 폴더 하나를 던지면 파일명 감정 키워드로 상태별 자동 분류·배치
# 사용:
#   powershell -File import-photos.ps1 -Persona haewon -Source "C:\...\haewon"
#   powershell -File import-photos.ps1 -Persona haewon -Source "..." -DryRun     (매핑만 미리보기)
#   powershell -File import-photos.ps1 -Persona kurisu -Source "..." -RemoveBg   (배경 균일한 렌더 투명화)
param(
    [Parameter(Mandatory=$true)][string]$Persona,
    [Parameter(Mandatory=$true)][string]$Source,
    [switch]$RemoveBg,
    [switch]$DryRun
)
Add-Type -AssemblyName System.Drawing
$base = Join-Path $env:USERPROFILE ".claude\mascot"
$pSafe = $Persona -replace '[^A-Za-z0-9_-]',''
$destRoot = Join-Path $base ("personas\" + $pSafe + "\images")

# 감정 키워드 → 상태 (위에서부터 먼저 매칭 = 구체적인 것 먼저)
$rules = @(
    @{ state='rejected'; rx='서운|슬픔|시무룩|우울|실망|삐진|삐짐|눈물|sad|cry' }
    @{ state='error';    rx='놀란|놀람|당황|충격|헉|띠용|surprise|shock' }
    @{ state='annoyed';  rx='짜증|화남|화난|분노|빡|어이|개같|열받|angry|mad' }
    @{ state='thanks';   rx='부끄|수줍|볼말|볼_|하트|heart|shy|blush|고마|땡큐' }
    @{ state='testing';  rx='긴장|초조|nervous' }
    @{ state='pushing';  rx='자신|당당|제법|비웃|어쩔|잘난|smirk|confident' }
    @{ state='committing'; rx='따봉|엄지|thumbs|오케이|굿잡' }
    @{ state='coding';   rx='집중|열심|주먹|파이팅|화이팅|잼민|타이핑|focus' }
    @{ state='thinking'; rx='생각|고민|궁금|갸웃|의문|think' }
    @{ state='waiting';  rx='기다|뚱|심심|멀뚱|wait|bored' }
    @{ state='done';     rx='웃음|웃는|웃참|기분\s*좋|좋은|행복|신남|좋아|뿌듯|최고|만족|해맑|미소|happy|smile|laugh' }
    @{ state='idle';     rx='그냥|평범|무표정|대기|보는|neutral' }
)

function Get-State([string]$name){
    foreach($r in $rules){ if($name -match $r.rx){ return $r.state } }
    return '_unsorted'
}
function Next-Index([string]$dir){ $n=1; while(Test-Path (Join-Path $dir "$n.jpg")){ $n++ }; return $n }

function Save-Image([string]$src,[string]$outJpg){
    if(-not $RemoveBg){ Copy-Item $src $outJpg -Force; return 'copy' }
    # 배경 균일하면 150px 축소 + 테두리 flood-fill 투명화(png) → outJpg 를 .png 로
    try {
        $orig = New-Object System.Drawing.Bitmap($src)
        $tw=150; $th=[int]([math]::Round($orig.Height*$tw/$orig.Width))
        $sm=New-Object System.Drawing.Bitmap($tw,$th,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $g=[System.Drawing.Graphics]::FromImage($sm); $g.InterpolationMode='HighQualityBicubic'
        $g.DrawImage($orig,0,0,$tw,$th); $g.Dispose(); $orig.Dispose()
        $rect=New-Object System.Drawing.Rectangle(0,0,$tw,$th)
        $d=$sm.LockBits($rect,'ReadWrite',[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $st=$d.Stride; $buf=New-Object byte[] ($st*$th)
        [System.Runtime.InteropServices.Marshal]::Copy($d.Scan0,$buf,0,$buf.Length)
        $bR=$buf[2];$bG=$buf[1];$bB=$buf[0]  # 좌상단 = 배경색 기준
        $vis=New-Object bool[] ($tw*$th); $stk=New-Object System.Collections.Generic.Stack[int]
        for($x=0;$x -lt $tw;$x++){ $stk.Push($x); $stk.Push((($th-1)*$tw)+$x) }
        for($y=0;$y -lt $th;$y++){ $stk.Push($y*$tw); $stk.Push(($y*$tw)+($tw-1)) }
        $tol=36; $cl=0
        while($stk.Count -gt 0){ $id=$stk.Pop(); if($vis[$id]){continue}; $vis[$id]=$true
            $px=$id%$tw; $py=[int]($id/$tw); $ix=($py*$st)+($px*4)
            if([math]::Abs($buf[$ix+2]-$bR)-gt $tol -or [math]::Abs($buf[$ix+1]-$bG)-gt $tol -or [math]::Abs($buf[$ix]-$bB)-gt $tol){continue}
            $buf[$ix+3]=0; $cl++
            if($px+1 -lt $tw){$stk.Push($id+1)}; if($px-1 -ge 0){$stk.Push($id-1)}
            if($py+1 -lt $th){$stk.Push($id+$tw)}; if($py-1 -ge 0){$stk.Push($id-$tw)}
        }
        [System.Runtime.InteropServices.Marshal]::Copy($buf,0,$d.Scan0,$buf.Length); $sm.UnlockBits($d)
        $ratio=$cl/($tw*$th)
        if($ratio -gt 0.1 -and $ratio -lt 0.85){
            $outPng=[System.IO.Path]::ChangeExtension($outJpg,'.png')
            $sm.Save($outPng,[System.Drawing.Imaging.ImageFormat]::Png); $sm.Dispose(); return 'bg-removed'
        } else { $sm.Dispose(); Copy-Item $src $outJpg -Force; return 'copy(bg?)' }
    } catch { Copy-Item $src $outJpg -Force; return 'copy(err)' }
}

$files = Get-ChildItem $Source -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|gif)$' }
$tally=@{}; $unsorted=@(); $skipped=@()
foreach($f in $files){
    # 유효 이미지 확인
    try { $im=[System.Drawing.Image]::FromFile($f.FullName); $im.Dispose() } catch { $skipped+=$f.Name; continue }
    $state = Get-State $f.BaseName
    if(-not $tally.ContainsKey($state)){ $tally[$state]=0 }
    $tally[$state]++
    if($state -eq '_unsorted'){ $unsorted+=$f.Name }
    if(-not $DryRun){
        $dir = Join-Path $destRoot $state
        New-Item -ItemType Directory -Force $dir | Out-Null
        $out = Join-Path $dir ((Next-Index $dir).ToString()+'.jpg')
        Save-Image $f.FullName $out | Out-Null
    }
}

Write-Host ("[{0}] {1} -> personas\{2}\images" -f $(if($DryRun){'DRY-RUN'}else{'IMPORT'}), $Source, $pSafe)
Write-Host "상태별 분류:"
$tally.GetEnumerator() | Sort-Object Name | ForEach-Object { Write-Host ("  {0,-11} {1}장" -f $_.Key,$_.Value) }
if($unsorted){ Write-Host ("`n미분류(파일명에 감정 키워드 없음, 직접 이동/이름변경 권장):"); $unsorted | ForEach-Object { Write-Host "  - $_" } }
if($skipped){ Write-Host ("`n건너뜀(이미지 아님, webp 등): " + ($skipped -join ', ')) }
