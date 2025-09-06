$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host "== Environment ==" -ForegroundColor Cyan
Write-Host ("PSVersion: {0}" -f $PSVersionTable.PSVersion)
Write-Host ("Path: {0}" -f (Get-Location))
Write-Host ("Has .env: {0}" -f (Test-Path ".env"))

Write-Host "\n== Docker ==" -ForegroundColor Cyan
try { docker --version } catch { Write-Error $_; exit 1 }
try { docker info --format '{{.ServerVersion}} / {{.OperatingSystem}}' } catch { Write-Warning "docker info failed: $_" }

Write-Host "\n== Compose detection ==" -ForegroundColor Cyan
$useV2 = $true
try { docker compose version } catch { try { docker-compose --version; $useV2 = $false } catch { Write-Error "No docker compose detected"; exit 1 } }
if ($useV2) { Write-Host "Using: docker compose" } else { Write-Host "Using: docker-compose" }

function Compose {
  param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
  if ($useV2) { docker compose @Args } else { docker-compose @Args }
}

Write-Host "\n== Compose config validation ==" -ForegroundColor Cyan
try { Compose config } catch { Write-Error "Compose config failed. $_"; exit 1 }

Write-Host "\n== Services status ==" -ForegroundColor Cyan
Compose ps

Write-Host "\n== DB health ==" -ForegroundColor Cyan
try {
  $status = docker inspect -f "{{.State.Health.Status}}" listmonk-db
  Write-Host ("DB container health: {0}" -f $status)
} catch { Write-Warning "DB container not found yet." }

Write-Host "\n== Recent logs (db) ==" -ForegroundColor Cyan
try { Compose logs --tail=50 db } catch { Write-Warning "No db logs." }

Write-Host "\n== Recent logs (app) ==" -ForegroundColor Cyan
try { Compose logs --tail=50 app } catch { Write-Warning "No app logs." }

Write-Host "\nDiagnosis complete." -ForegroundColor Green

