param(
  [switch]$Recreate
)

$ErrorActionPreference = 'Stop'

Write-Host "Initializing listmonk DB (docker compose)" -ForegroundColor Cyan

if ($Recreate) {
  docker compose down -v
}

# Ensure DB is up
docker compose up -d db

Write-Host "Running one-time installation..." -ForegroundColor Yellow
docker compose run --rm app ./listmonk --install --yes

Write-Host "Starting app..." -ForegroundColor Green
docker compose up -d app

Write-Host "Open http://localhost:$env:LISTMONK_PORT (or 9000)" -ForegroundColor Green

