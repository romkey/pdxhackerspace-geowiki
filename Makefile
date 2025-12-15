.PHONY: build up down logs shell console test migrate seed clean

build:
	docker-compose build

up:
	docker-compose up

down:
	docker-compose down

logs:
	docker-compose logs -f web

shell:
	docker-compose exec web bash

console:
	docker-compose exec web rails console

test:
	docker-compose run --rm test

migrate:
	docker-compose exec web rails db:migrate

seed:
	docker-compose exec web rails db:seed

setup:
	docker-compose build
	docker-compose up -d db
	sleep 5
	docker-compose exec web rails db:create db:migrate

clean:
	docker-compose down -v
	docker system prune -f

