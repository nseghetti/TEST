param(
  [switch]$Logs
)

$ErrorActionPreference = 'Stop'

# Switch to project root (one level up from scripts/)
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

if (-not (Test-Path '.env')) {
  Write-Host "Hint: .env not found. Copy .env.example to .env" -ForegroundColor Yellow
}

Write-Host "Starting listmonk services (db + app)..." -ForegroundColor Cyan
docker compose up -d db app

# PowerShell 5.1 compatibility: avoid inline if expression
$port = $env:LISTMONK_PORT
if (-not $port) { $port = '9000' }
Write-Host ("Open http://localhost:{0}" -f $port) -ForegroundColor Green

if ($Logs) {
  Write-Host "Tailing app logs (Ctrl+C to stop)..." -ForegroundColor Yellow
  docker compose logs -f app
}
