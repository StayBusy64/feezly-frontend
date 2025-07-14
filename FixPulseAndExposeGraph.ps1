<#
.SYNOPSIS
  Expose the ForceGraph3D instance globally and guard against missing nodes in the pulse script.

.DESCRIPTION
  - In `feezly-3d-brain.html`, replaces
      const Graph = ForceGraph3D()...
    with
      window.Graph = ForceGraph3D()...
  - In `pulse-animation.js`, wraps the node lookup in a guard so it skips unknown IDs instead of throwing.
  - Stages, commits, and pushes the changes.
#>

# --- CONFIG ---
$repoRoot      = "C:\Users\Stayb\Documents\feezly-frontend"
$htmlPath      = "public\brain\feezly-3d-brain.html"
$pulsePath     = "public\brain\pulse-animation.js"
$commitMessage = "🔧 Expose Graph & guard missing nodes in pulse script"
# --------------

Set-Location $repoRoot

# 1) Patch HTML to expose Graph globally
$htmlFull = Join-Path $repoRoot $htmlPath
(Get-Content $htmlFull -Raw) `
  -replace 'const\s+Graph\s*=\s*ForceGraph3D\(', 'window.Graph = ForceGraph3D(' `
  | Set-Content $htmlFull -Encoding UTF8
Write-Host "✅ Patched $htmlPath to expose window.Graph"

# 2) Patch pulse-animation.js to guard missing nodes
$pulseFull = Join-Path $repoRoot $pulsePath
$pulseText = Get-Content $pulseFull -Raw

$guarded = $pulseText -replace (
  'const\s+nodeObj\s*=\s*Graph\.nodeThreeObjectMap\(\)\s*\[\s*evt\.nodeId\s*\]',
@'
const nodesMap = window.Graph.nodeThreeObjectMap();
if (!nodesMap[evt.nodeId]) {
  console.warn(`Skipping unknown node ${evt.nodeId}`);
  return;
}
const nodeObj = nodesMap[evt.nodeId]
'@)

$guarded | Set-Content $pulseFull -Encoding UTF8
Write-Host "✅ Patched $pulsePath to skip unknown nodes"

# 3) Commit & push
git add $htmlPath $pulsePath
git commit -m $commitMessage
git push origin main

Write-Host "🚀 Done! Patches pushed. Please trigger a Render manual deploy to pick up the fix."
