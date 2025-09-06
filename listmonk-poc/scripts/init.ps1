param(
  [switch]$Recreate
)

$ErrorActionPreference = 'Stop'

# Switch to project root (one level up from scripts/)
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

if (-not (Test-Path 'docker-compose.yml')) {
  throw "docker-compose.yml not found in $projectRoot. Run this script from the repo or restore files."
}

Write-Host "Initializing listmonk (compose at: $((Resolve-Path 'docker-compose.yml').Path))" -ForegroundColor Cyan

# Check Docker availability
try { docker --version | Out-Null } catch { throw "Docker is not available. Install/start Docker Desktop." }

# Detect compose (v2 preferred, fallback to v1)
$script:UseV2 = $true
try {
  docker compose version | Out-Null
} catch {
  try {
    docker-compose --version | Out-Null
    $script:UseV2 = $false
  } catch {
    throw "Neither 'docker compose' (v2) nor 'docker-compose' (v1) is available."
  }
}

function Compose {
  param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
  if ($script:UseV2) { docker compose @Args } else { docker-compose @Args }
}

if ($Recreate) { Compose down -v }

if (-not (Test-Path '.env')) {
  Write-Host "Hint: .env not found. Copy .env.example to .env" -ForegroundColor Yellow
}

# Ensure DB is up
Compose up -d db

# Wait for db health
Write-Host "Waiting for database to become healthy..." -ForegroundColor Yellow
$max = 30; $i = 0
while ($i -lt $max) {
  $status = (docker inspect -f "{{.State.Health.Status}}" listmonk-db 2>$null)
  if ($status -eq 'healthy') { break }
  Start-Sleep -Seconds 5
  $i++
}
if ($i -ge $max) { Write-Warning "Database did not become healthy in time; continuing anyway." }

Write-Host "Running one-time installation..." -ForegroundColor Yellow
try {
  Compose run --rm app ./listmonk --install --yes
} catch {
  Write-Warning "Install failed (possibly already installed). Proceeding to start the app."
}

Write-Host "Starting app..." -ForegroundColor Green
Compose up -d app

# PowerShell 5.1 compatibility: avoid null-coalescing operator
$port = $env:LISTMONK_PORT
if (-not $port) { $port = '9000' }
Write-Host ("Open http://localhost:{0}" -f $port) -ForegroundColor Green
