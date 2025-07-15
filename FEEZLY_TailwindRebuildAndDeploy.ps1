<#
.SYNOPSIS
    Fix Tailwind/PostCSS, rebuild frontend, auto-deploy to GitHub.
    Includes Node.js memory fix for large builds.
#>

$ErrorActionPreference = "Stop"
$projectRoot = "C:\Users\Stayb\Documents\feezly-frontend"
Set-Location $projectRoot

Write-Host "`n[+] Starting Tailwind/PostCSS Recovery + Build + Deploy..." -ForegroundColor Cyan

# STEP 1: Install deps
Write-Host "[*] Installing Tailwind + PostCSS deps..." -ForegroundColor Yellow
npm install -D tailwindcss postcss autoprefixer @tailwindcss/postcss

# STEP 2: Create configs if missing
$postcssPath = Join-Path $projectRoot "postcss.config.js"
if (-not (Test-Path $postcssPath)) {
    Set-Content $postcssPath @'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {}
  }
}
'@
    Write-Host "[OK] Created postcss.config.js" -ForegroundColor Green
}

$tailwindPath = Join-Path $projectRoot "tailwind.config.js"
if (-not (Test-Path $tailwindPath)) {
    Set-Content $tailwindPath @'
/** @type {import("tailwindcss").Config} */
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx}",
    "./pages/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}"
  ],
  theme: {
    extend: {}
  },
  plugins: []
}
'@
    Write-Host "[OK] Created tailwind.config.js" -ForegroundColor Green
}

# STEP 3: Clean artifacts
Write-Host "[*] Cleaning node_modules, .next, package-lock.json..." -ForegroundColor Yellow
Remove-Item -Recurse -Force "node_modules", ".next", "package-lock.json" -ErrorAction SilentlyContinue
npm cache clean --force

# STEP 4: Reinstall
Write-Host "[*] Reinstalling packages..." -ForegroundColor Yellow
npm install

# STEP 5: Boost memory + Build
Write-Host "[*] Rebuilding frontend with 8GB memory cap..." -ForegroundColor Yellow
$env:NODE_OPTIONS="--max_old_space_size=8192"
$buildOutput = npm run build 2>&1

# STEP 6: Deploy if successful
if ($buildOutput -match "compiled successfully" -or $buildOutput -match "Next.js build completed") {
    Write-Host "`n[✓] Build completed successfully!" -ForegroundColor Green
    git add .
    git commit -m "Tailwind PostCSS fix and memory-safe rebuild"
    git push origin main
    Write-Host "[✓] Pushed to GitHub. Vercel should auto-deploy." -ForegroundColor Cyan
} else {
    Write-Host "`n[!] Build failed. Check logs above." -ForegroundColor Red
}
