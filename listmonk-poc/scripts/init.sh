#!/usr/bin/env sh
set -euo pipefail

# Change to project root (parent of scripts/)
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "Initializing listmonk (compose at: $(pwd)/docker-compose.yml)"

if [ "${1-}" = "--recreate" ]; then
  docker compose down -v
fi

if [ ! -f .env ]; then
  echo "Hint: .env not found. Copy .env.example to .env" >&2
fi

docker compose up -d db
echo "Running one-time installation..."
docker compose run --rm app ./listmonk --install --yes
echo "Starting app..."
docker compose up -d app
echo "Open http://localhost:${LISTMONK_PORT:-9000}"
