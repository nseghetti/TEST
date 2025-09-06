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
try {
  docker --version | Out-Null
  docker compose version | Out-Null
} catch {
  throw "Docker Desktop or docker compose is not available. Please install/start Docker Desktop."
}

if ($Recreate) {
  docker compose down -v
}

if (-not (Test-Path '.env')) {
  Write-Host "Hint: .env not found. Copy .env.example to .env" -ForegroundColor Yellow
}

# Ensure DB is up
docker compose up -d db

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
  docker compose run --rm app ./listmonk --install --yes
} catch {
  Write-Warning "Install failed (possibly already installed). Proceeding to start the app."
}

Write-Host "Starting app..." -ForegroundColor Green
docker compose up -d app

Write-Host "Open http://localhost:$($env:LISTMONK_PORT -as [string] ?? '9000')" -ForegroundColor Green
