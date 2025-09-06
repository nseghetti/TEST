SHELL := /bin/sh

.PHONY: dev up down logs install upgrade ps status

dev: up

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f app

install:
	docker compose up -d db
	sleep 5
	-docker compose run --rm app ./listmonk --install --yes

upgrade:
	docker compose run --rm app ./listmonk --upgrade --yes

ps status:
	docker compose ps

