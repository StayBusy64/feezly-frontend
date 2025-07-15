<#
.SYNOPSIS
Launch FEEZLY 3D Brain via Localhost HTTP Server

.DESCRIPTION
Serves the /public directory over HTTP using Python, then opens the brain map in a real browser URL to avoid CORS issues.

.SAVES AS
FEEZLY_LaunchLocalBrain.ps1 (only if not already saved)

.AUTHOR
ChatGPT for Mai-Nihguh
#>

$PublicPath     = "C:\Users\Stayb\Documents\feezly-frontend\public"
$BrainPath      = "brain\feezly-3d-brain.html"
$GraphPath      = "brain\graph.json"
$Port           = 8080
$LaunchUrl      = "http://localhost:$Port/$BrainPath"
$SelfScriptName = "FEEZLY_LaunchLocalBrain.ps1"
$SelfPath       = Join-Path $PublicPath $SelfScriptName

# Ensure HTML file exists
if (-not (Test-Path (Join-Path $PublicPath $BrainPath))) {
    Write-Host "❌ ERROR: feezly-3d-brain.html not found at expected path:" -ForegroundColor Red
    Write-Host "`t$PublicPath\$BrainPath"
    exit 1
}

# Ensure graph.json exists (optional but ideal)
if (-not (Test-Path (Join-Path $PublicPath $GraphPath))) {
    Write-Host "⚠️ WARNING: graph.json not found — the brain may load empty." -ForegroundColor Yellow
}

# Start HTTP server from /public
Write-Host "🚀 Launching Python server from:" $PublicPath -ForegroundColor Cyan
Set-Location $PublicPath
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd `"$PublicPath`"; python -m http.server $Port" -WindowStyle Hidden

# Wait for it to spin up
Start-Sleep -Seconds 2

# Launch HTML in browser using localhost URL
Write-Host "🌐 Opening browser to:" $LaunchUrl -ForegroundColor Green
Start-Process $LaunchUrl

# Self-save this script if not yet saved
if ($MyInvocation.MyCommand.Path -and (-not (Test-Path $SelfPath))) {
    Get-Content -Raw -Path $MyInvocation.MyCommand.Path | Set-Content -Path $SelfPath
    Write-Host "💾 Script saved as: $SelfPath" -ForegroundColor DarkGreen
}
