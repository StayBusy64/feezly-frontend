$projectRoot = "$PSScriptRoot"
$packageJsonPath = Join-Path $projectRoot "package.json"

if (!(Test-Path $packageJsonPath)) {
    Write-Host "❌ package.json not found in: $projectRoot"
    $create = Read-Host "Would you like to generate a clean one now? (yes/no)"
    if ($create -eq "yes") {
        $jsonContent = @"
{
  "name": "frontend",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "14.2.3",
    "react": "18.2.0",
    "react-dom": "18.2.0"
  },
  "devDependencies": {
    "eslint": "8.56.0",
    "tailwindcss": "3.4.1",
    "postcss": "8.4.38",
    "autoprefixer": "10.4.18",
    "typescript": "5.4.5"
  }
}
"@
        $jsonContent | Set-Content $packageJsonPath -Encoding utf8
        Write-Host "✅ Clean package.json created."
    } else {
        Write-Host "⛔ Exiting — no file created."
        Read-Host "Press Enter to exit"
        exit 1
    }
}

try {
    $json = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
    Write-Host "✅ JSON is valid."
} catch {
    Write-Error "❌ Invalid JSON. Fix it manually."
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "🔧 Normalizing CRLF to LF..."
(Get-Content $packageJsonPath -Raw) -replace "`r`n", "`n" | Set-Content $packageJsonPath -Encoding utf8

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText($packageJsonPath, [System.IO.File]::ReadAllText($packageJsonPath), $utf8NoBom)

Write-Host "🔁 Committing via Git..."
git config core.autocrlf input
git add --renormalize $packageJsonPath
git commit -m "🛠 Fix: Normalize package.json for Vercel"
git push

Write-Host "`n✅ Done. You may redeploy now."
Read-Host "Press Enter to exit"
