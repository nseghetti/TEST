#!/usr/bin/env sh
set -euo pipefail

echo "Initializing listmonk DB (docker compose)"

if [ "${1-}" = "--recreate" ]; then
  docker compose down -v
fi

docker compose up -d db
echo "Running one-time installation..."
docker compose run --rm app ./listmonk --install --yes
echo "Starting app..."
docker compose up -d app
echo "Open http://localhost:${LISTMONK_PORT:-9000}"

