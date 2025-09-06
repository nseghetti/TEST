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

if ($Recreate) {
  docker compose down -v
}

if (-not (Test-Path '.env')) {
  Write-Host "Hint: .env not found. Copy .env.example to .env" -ForegroundColor Yellow
}

# Ensure DB is up
docker compose up -d db

Write-Host "Running one-time installation..." -ForegroundColor Yellow
docker compose run --rm app ./listmonk --install --yes

Write-Host "Starting app..." -ForegroundColor Green
docker compose up -d app

Write-Host "Open http://localhost:$($env:LISTMONK_PORT -as [string] ?? '9000')" -ForegroundColor Green
