# ReInject3DBrain.ps1
# Regenerates the 3D brain map in public/brain and pushes it to GitHub

# === CONFIGURE THESE PATHS ===
$repoRoot  = "C:\Users\Stayb\Documents\feezly-frontend"
$cortexCsv = "C:\Users\Stayb\Documents\feezly\Cognition\Cortex\CortexMap.csv"
# =============================

Set-Location $repoRoot

# 1) Ensure the target folder exists
$brainDir = Join-Path $repoRoot "public\brain"
if (-not (Test-Path $brainDir)) {
  New-Item -ItemType Directory -Path $brainDir -Force | Out-Null
  Write-Host "✅ Created $brainDir"
}

# 2) Write the HTML file
$html = @"
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>FEEZLY 3D Brain</title>
  <style> html,body{margin:0;overflow:hidden;background:#000} </style>
</head>
<body>
  <script src="https://unpkg.com/three@0.130.1/build/three.min.js"></script>
  <script src="https://unpkg.com/three-forcegraph"></script>
  <script>
    const Graph = ForceGraph3D()(document.body)
      .nodeColor(n=>n.zone||'white')
      .nodeThreeObject(n=>{
        const s=new THREE.Sprite(new THREE.SpriteMaterial({color:n.color||'cyan'}));
        s.scale.set(6,6,1); return s;
      })
      .linkWidth(0.5).linkColor(()=> 'gray')
      .backgroundColor('black').showNavInfo(false);
    fetch('graph.json').then(r=>r.json()).then(data=>Graph.graphData(data));
    window.addEventListener('resize',()=>{
      const camera = Graph.camera();
      camera.aspect = window.innerWidth/window.innerHeight;
      camera.updateProjectionMatrix();
      Graph.renderer().setSize(window.innerWidth, window.innerHeight);
    });
  </script>
</body>
</html>
"@
$html | Set-Content (Join-Path $brainDir "feezly-3d-brain.html") -Encoding UTF8
Write-Host "✅ Wrote feezly-3d-brain.html"

# 3) Build graph.json from CSV
$nodes = @{}
$links = @()

Import-Csv $cortexCsv | ForEach-Object {
  $src   = $_.source
  $tgt   = $_.target
  $znRaw = $_.zone
  # default zone to "Core" if empty
  $zone = if ($null -ne $znRaw -and $znRaw.Trim() -ne "") { $znRaw.Trim() } else { "Core" }

  if (-not $nodes.ContainsKey($src)) {
    $nodes[$src] = @{ id = $src; zone = $zone }
  }
  if (-not $nodes.ContainsKey($tgt)) {
    $nodes[$tgt] = @{ id = $tgt; zone = $zone }
  }
  $links += @{ source = $src; target = $tgt }
}

$graph = @{ nodes = $nodes.Values; links = $links } | ConvertTo-Json -Depth 5
$graph | Set-Content (Join-Path $brainDir "graph.json") -Encoding UTF8
Write-Host "✅ Wrote graph.json"

# 4) Commit & push
git add public/brain/feezly-3d-brain.html public/brain/graph.json
git commit -m "📂 Regenerate 3D brain map under public/brain"
git push origin main

Write-Host "`n🚀 Done! Now trigger a Render deploy and open:"
Write-Host "   https://feezly-frontend.onrender.com/brain/feezly-3d-brain.html" -ForegroundColor Cyan
