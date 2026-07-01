# Stop: if a permission prompt was left unresolved (flag still set) => user rejected
$base = Join-Path $env:USERPROFILE ".claude\mascot"
$flag = Join-Path $base "pending.flag"
if (Test-Path $flag) {
    Remove-Item $flag -Force -ErrorAction SilentlyContinue
    & (Join-Path $base "set-state.ps1") rejected
} else {
    & (Join-Path $base "set-state.ps1") done
}
