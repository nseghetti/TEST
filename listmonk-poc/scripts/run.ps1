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

if (-not (Test-Path '.env')) {
  Write-Host "Hint: .env not found. Copy .env.example to .env" -ForegroundColor Yellow
}

Write-Host "Starting listmonk services (db + app)..." -ForegroundColor Cyan
Compose up -d db app

# PowerShell 5.1 compatibility: avoid inline if expression
$port = $env:LISTMONK_PORT
if (-not $port) { $port = '9000' }
Write-Host ("Open http://localhost:{0}" -f $port) -ForegroundColor Green

if ($Logs) {
  Write-Host "Tailing app logs (Ctrl+C to stop)..." -ForegroundColor Yellow
  Compose logs -f app
}
