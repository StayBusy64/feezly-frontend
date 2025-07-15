# ========================================
# 🔥 FEEZLY Conflict Hunter & Nuker Script
# Finds and destroys conflicting Next.js route files
# ========================================

$projectDir = "C:\Users\Stayb\Documents\feezly-frontend"
Set-Location $projectDir

$conflictingFiles = @(
    "pages/index.js",
    "app/page.tsx"
)

foreach ($file in $conflictingFiles) {
    $filePath = Join-Path $projectDir $file
    if (Test-Path $filePath) {
        Remove-Item $filePath -Force
        Write-Host "✅ Nuked file: $file" -ForegroundColor Green
    } else {
        Write-Host "⚠️ File not found (already deleted?): $file" -ForegroundColor Yellow
    }
}

# Stage deletions, commit, and push instantly.
git add -u
git commit -m "🔥 Nuked conflicting Next.js files (pages/index.js & app/page.tsx)"
git push origin main

Write-Host "🚀 Done! Redeploy now on Vercel with cleared cache!" -ForegroundColor Cyan
