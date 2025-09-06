param(
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

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

if (-not $Force) {
  $answer = Read-Host "This will stop containers and remove volumes (data). Proceed? (y/N)"
  if ($answer -ne 'y' -and $answer -ne 'Y') {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 0
  }
}

Write-Host "Stopping and removing containers + volumes..." -ForegroundColor Cyan
Compose down -v
Write-Host "Done. You can re-run init with scripts/init.ps1" -ForegroundColor Green
