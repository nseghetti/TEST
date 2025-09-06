# Repository Guidelines

## Project Structure & Module Organization
- Source code: place application modules in `src/` grouped by domain (e.g., `src/api/`, `src/core/`).
- Tests: mirror source layout in `tests/` (e.g., `tests/api/`, `tests/core/`).
- Scripts: helper CLIs and automation in `scripts/` (PowerShell or Bash).
- Docs & assets: `docs/` for guides, `assets/` for images/fixtures; small example projects in `examples/`.
- Configuration: keep environment samples in `.env.example`; do not commit real secrets.

## Build, Test, and Development Commands
- Build: use a project-specific task runner if present — `make build`, `npm run build`, or `python -m build`.
- Test: `make test`, `npm test`, or `pytest -q` depending on stack.
- Lint/format: `make lint`, `npm run lint && npm run format`, or `ruff check && ruff format`.
- Run locally: `make dev`, `npm run dev`, or `python -m src`.
Note: prefer the Makefile or package.json scripts when available; they encode repo defaults.

## Coding Style & Naming Conventions
- Indentation: 2 spaces for web (JS/TS), 4 spaces for Python; no tabs.
- Names: `kebab-case` for folders/files, `snake_case` for Python, `camelCase` for variables/functions, `PascalCase` for types/classes.
- Formatting: use the language formatter (Prettier for JS/TS, Black for Python, gofmt for Go). Commit only formatted code.

## Testing Guidelines
- Frameworks: Jest/Vitest for JS/TS, Pytest for Python (use fixtures and parametrization).
- Structure: mirror source layout; name files `*.spec.ts` / `*.test.ts` or `test_*.py`.
- Coverage: target ≥ 80% on changed code; add tests with every feature/fix.
- Running: prefer `make test` or the package script so CI matches local.

## Commit & Pull Request Guidelines
- Commits: follow Conventional Commits (e.g., `feat: add user audit trail`). Keep changes focused and messages imperative.
- PRs: include a clear summary, rationale, linked issues (e.g., `Closes #123`), screenshots for UI, and test notes. Ensure CI is green and conflicts resolved.

## Security & Configuration Tips
- Secrets: never commit credentials. Use `.env` locally and update `.env.example` when vars change.
- Reviews: flag dependencies touching auth, crypto, or persistence for extra review.

## Agent-Specific Instructions
- Prefer ripgrep for search (`rg`) and small, targeted diffs; edit files via `apply_patch`.
- Read files in ≤250-line chunks; avoid broad rewrites.
- Keep a lightweight plan and update it as steps complete.
