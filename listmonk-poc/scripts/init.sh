#!/usr/bin/env sh
set -euo pipefail

# Change to project root (parent of scripts/)
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "Initializing listmonk (compose at: $(pwd)/docker-compose.yml)"

# Check Docker availability
if ! docker --version >/dev/null 2>&1; then
  echo "Docker is not available. Install/start Docker Desktop." >&2
  exit 1
fi

# Compose wrapper (prefer v2, fallback to v1)
compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  elif docker-compose --version >/dev/null 2>&1; then
    docker-compose "$@"
  else
    echo "Neither 'docker compose' (v2) nor 'docker-compose' (v1) is available." >&2
    return 127
  fi
}

if [ "${1-}" = "--recreate" ]; then
  compose down -v
fi

if [ ! -f .env ]; then
  echo "Hint: .env not found. Copy .env.example to .env" >&2
fi

compose up -d db

echo "Waiting for database to become healthy..."
COUNT=0
until [ "$COUNT" -ge 30 ]; do
  STATUS=$(docker inspect -f '{{.State.Health.Status}}' listmonk-db 2>/dev/null || echo "")
  [ "$STATUS" = "healthy" ] && break
  COUNT=$((COUNT+1))
  sleep 5
done
[ "$COUNT" -ge 30 ] && echo "DB health not confirmed; continuing anyway." >&2 || true

echo "Running one-time installation..."
if ! compose run --rm app ./listmonk --install --yes; then
  echo "Install failed (possibly already installed). Proceeding..." >&2
fi
echo "Starting app..."
compose up -d app
echo "Open http://localhost:${LISTMONK_PORT:-9000}"
