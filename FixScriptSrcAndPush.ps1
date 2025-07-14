<# 
.SYNOPSIS
  Robust patch + pull/rebase + commit + push for feezly-frontend.
#>

#–– 0) Figure out where “here” is ––
$root = if ($PSScriptRoot -and $PSScriptRoot -ne '') {
    $PSScriptRoot
} else {
    (Get-Location).Path
}

$htmlPath  = Join-Path $root 'public\brain\feezly-3d-brain.html'
$pulsePath = Join-Path $root 'public\brain\pulse-animation.js'

Push-Location $root

#–– 1) Sync with remote so we’re not behind ––
Write-Host "🔄 Fetching & rebasing remote changes…" -NoNewline
git fetch origin main   2>$null
git rebase origin/main  2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Rebase failed. Resolve conflicts manually and rerun."
    Pop-Location; exit 1
}
Write-Host " done."

#–– 2) Patch HTML → 3d-force-graph bundle ––
if (Test-Path $htmlPath) {
    $orig  = Get-Content $htmlPath -Raw
    $fixed = $orig -replace '<script src="https://unpkg\.com/three-forcegraph"></script>', '<script src="https://unpkg.com/3d-force-graph"></script>'
    if ($fixed -ne $orig) {
        $fixed | Set-Content $htmlPath -Encoding UTF8
        Write-Host "✅ Patched $htmlPath"
    } else {
        Write-Host "ℹ️  No three-forcegraph tag found in $htmlPath"
    }
} else {
    Write-Host "⚠️  Missing file: $htmlPath"
}

#–– 3) Guard-patch pulse script ––
if (Test-Path $pulsePath) {
    $orig   = Get-Content $pulsePath -Raw
    $guarded = $orig -replace 'nodes\.forEach\([^)]*\{','nodes.forEach(node => { if (!node) return;'
    if ($guarded -ne $orig) {
        $guarded | Set-Content $pulsePath -Encoding UTF8
        Write-Host "✅ Patched $pulsePath"
    } else {
        Write-Host "ℹ️  pulse-animation.js already has guard"
    }
} else {
    Write-Host "⚠️  No pulse-animation.js found, skipping"
}

#–– 4) Stage tracked changes only ––
git add -u

#–– 5) Commit if needed ––
$commitMsg = '🐛 Fix HTML script src + pulse guard'
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    git commit -m $commitMsg
    Write-Host "💾 Committed changes."
} else {
    Write-Host "🗂️  Nothing new to commit."
}

#–– 6) Push & confirm ––
Write-Host "🚀 Pushing to origin/main…" -NoNewline
git push origin main 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host " done.`n✅ All set! Please trigger a Render manual deploy to pick up the fix."
} else {
    Write-Host "`n❌ Push still failed. Resolve manually or run 'git pull --rebase'."
    Pop-Location; exit 1
}

Pop-Location
