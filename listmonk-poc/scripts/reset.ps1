param(
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

if (-not (Test-Path 'docker-compose.yml')) {
  throw "docker-compose.yml not found in $projectRoot."
}

try {
  docker --version | Out-Null
  docker compose version | Out-Null
} catch {
  throw "Docker Desktop or docker compose is not available."
}

if (-not $Force) {
  $answer = Read-Host "This will stop containers and remove volumes (data). Proceed? (y/N)"
  if ($answer -ne 'y' -and $answer -ne 'Y') {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 0
  }
}

Write-Host "Stopping and removing containers + volumes..." -ForegroundColor Cyan
docker compose down -v
Write-Host "Done. You can re-run init with scripts/init.ps1" -ForegroundColor Green

