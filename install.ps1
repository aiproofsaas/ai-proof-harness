# Installs or updates the AI-Proof harness in the current folder, on Windows.
# Safe to run again: harness files get replaced, your own files never do.
$ErrorActionPreference = "Stop"

$Repo = "aiproofsaas/ai-proof-harness"
$Dest = (Get-Location).Path
$HomeDir = [Environment]::GetFolderPath("UserProfile")

$Blocked = @($HomeDir, (Join-Path $HomeDir "Desktop"), (Join-Path $HomeDir "Documents"), (Join-Path $HomeDir "Downloads"))
if ($Blocked -contains $Dest.TrimEnd('\', '/')) {
  Write-Host "Stop: this is $Dest. Make a project folder first, like C:\Users\<you>\ai-proof, open it, and run this again."
  exit 1
}
if ($Dest -like "*OneDrive*") {
  Write-Host "Warning: this folder is inside OneDrive. OneDrive locks files while you build. Move it to C:\Users\<you>\ai-proof when you can."
}

$Tmp = Join-Path ([IO.Path]::GetTempPath()) ("aiproof-" + [Guid]::NewGuid())
New-Item -ItemType Directory -Path $Tmp | Out-Null

try {
  if ($env:AIPROOF_SRC) {
    $Src = $env:AIPROOF_SRC   # for testing a local copy
  } else {
    Write-Host "Downloading the AI-Proof harness..."
    $Zip = Join-Path $Tmp "harness.zip"
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/$Repo/archive/refs/heads/main.zip" -OutFile $Zip
    Expand-Archive -Path $Zip -DestinationPath $Tmp -Force
    $Src = (Get-ChildItem -Path $Tmp -Directory | Select-Object -First 1).FullName
  }

  $Old = ""
  $VersionFile = Join-Path $Dest "VERSION"
  if (Test-Path $VersionFile) { $Old = (Get-Content $VersionFile -Raw).Trim() }

  # Harness files: always the newest version.
  $Skills = Join-Path $Dest ".claude\skills"
  $Hooks = Join-Path $Dest ".claude\hooks"
  New-Item -ItemType Directory -Force -Path $Skills, $Hooks | Out-Null
  Get-ChildItem -Path (Join-Path $Src "harness\.claude\skills") -Directory | ForEach-Object {
    $Target = Join-Path $Skills $_.Name
    if (Test-Path $Target) { Remove-Item -Recurse -Force $Target }
    Copy-Item -Recurse -Path $_.FullName -Destination $Target
  }
  Copy-Item -Force -Path (Join-Path $Src "harness\.claude\hooks\*") -Destination $Hooks
  Copy-Item -Force -Path (Join-Path $Src "harness\.claude\settings.json") -Destination (Join-Path $Dest ".claude\settings.json")
  foreach ($File in @("HARNESS.md", "START-HERE.md", "VERSION")) {
    Copy-Item -Force -Path (Join-Path $Src "harness\$File") -Destination (Join-Path $Dest $File)
  }
  $Templates = Join-Path $Dest "templates"
  if (Test-Path $Templates) { Remove-Item -Recurse -Force $Templates }
  Copy-Item -Recurse -Path (Join-Path $Src "harness\templates") -Destination $Templates

  # Your files: only added when missing.
  $Starter = Join-Path $Src "starter"
  Get-ChildItem -Path $Starter -Recurse -File -Force | ForEach-Object {
    $Relative = $_.FullName.Substring($Starter.Length).TrimStart('\', '/')
    $Target = Join-Path $Dest $Relative
    if (-not (Test-Path $Target)) {
      New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
      Copy-Item -Path $_.FullName -Destination $Target
    }
  }

  $ClaudeMd = Join-Path $Dest "CLAUDE.md"
  if (-not (Test-Path $ClaudeMd)) {
    Copy-Item -Path (Join-Path $Templates "CLAUDE.md") -Destination $ClaudeMd
  } elseif (-not (Select-String -Path $ClaudeMd -Pattern "@HARNESS.md" -SimpleMatch -Quiet)) {
    Add-Content -Path $ClaudeMd -Value "`n@HARNESS.md"
  }

  $GitIgnore = Join-Path $Dest ".gitignore"
  if ((Test-Path $GitIgnore) -and -not ((Get-Content $GitIgnore) -contains ".dev.vars")) {
    Add-Content -Path $GitIgnore -Value "`n.dev.vars"
  }

  $New = (Get-Content $VersionFile -Raw).Trim()
  if (-not $Old) { Write-Host "Installed the AI-Proof harness, version $New." }
  elseif ($Old -eq $New) { Write-Host "Already up to date, version $New." }
  else { Write-Host "Updated from version $Old to $New." }
  Write-Host "Next: type /setup-check. If Claude doesn't know it yet, open a new session in this folder first."
}
finally {
  Remove-Item -Recurse -Force $Tmp -ErrorAction SilentlyContinue
}
