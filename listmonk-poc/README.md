# Listmonk POC

A minimal Docker Compose setup to evaluate listmonk locally.

## Prerequisites
- Docker Desktop (with Docker Compose)

## Quick start
1. Copy envs and set a strong DB password:
   - Windows: `copy .env.example .env`
   - macOS/Linux: `cp .env.example .env`
2. Start DB and run one-time install, then start app:
   - Windows PowerShell: `./scripts/init.ps1`
   - macOS/Linux: `sh ./scripts/init.sh`
3. Open http://localhost:9000 (or the port in `.env`).
   - Default admin credentials are shown during install; change them after login.

## Common commands
- `docker compose up -d db` — start PostgreSQL only.
- `docker compose run --rm app ./listmonk --install --yes` — initialize DB (first run only).
- `docker compose up -d app` — start listmonk.
- `docker compose logs -f app` — tail app logs.
- `docker compose down` — stop containers (use `-v` to remove volumes).

### Windows shortcuts
- `./scripts/run.ps1` — start DB and app; add `-Logs` to follow logs.
- `./scripts/reset.ps1` — stop stack and remove volumes (data loss). Use `-Force` to skip prompt.

## Configuration
- Adjust `.env` for DB credentials and port.
- For reverse proxies, set `BASE_URL` and pass through to the app env (see `docker-compose.yml`).

## Notes
- Upgrades: after image update, run `docker compose run --rm app ./listmonk --upgrade --yes` if migrations are required.
- Data persists in the `db-data` Docker volume.
