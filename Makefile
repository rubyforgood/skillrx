# Project configuration

# Docker uses the directory environment variable to set a prefix for the service's container names.
# Doc: https://docs.docker.com/compose/how-tos/environment-variables/envvars/#compose_project_name
PROJECT_NAME := sk

# Colors for terminal output (optional)
BLUE := \033[34m
RESET := \033[0m

# Commands configuration
COMPOSE_CMD = COMPOSE_PROJECT_NAME=$(PROJECT_NAME) docker compose -f docker-compose.dev.yml
EXEC_CMD = $(COMPOSE_CMD) exec app

.PHONY: help build rebuild stop start restart logs shell console format test test_fast db_reset migrate clean clean_volumes

# Default target
help:
	@echo "$(BLUE)Available commands:$(RESET)"
	@echo "  make build                      - Build image containers"
	@echo "  make rebuild                    - Clean, build, start containers and prepare database"
	@echo "  make stop [service]             - Stop all containers or a specific service"
	@echo "  make start [service]            - Start all containers or a specific service"
	@echo "  make restart [service]          - Restart all containers or a specific service"
	@echo "  make logs [service]             - View logs of all containers or a specific service"
	@echo "  make shell                      - Open a bash shell in the app container"
	@echo "  make console                    - Start Rails console"
	@echo "  make format                     - Auto-format code with Rubocop"
	@echo "  make test [FILE=path]           - Run all tests or specific file"
	@echo "  make test_fast [FILE=path]      - Run all tests or specific file and stop on first failure"
	@echo "  make migrate                    - Run database migrations"
	@echo "  make db_reset                   - Reset and rebuild database"
	@echo "  make clean                      - Remove all containers and volumes"
	@echo "  make clean_volumes              - Remove all volumes"

build:
	$(COMPOSE_CMD) build
	@echo "✅ Build complete!"

rebuild:
	@echo "🚀 Setting up..."
	make clean
	make build
	make start
	sleep 2
	$(EXEC_CMD) bundle exec rails db:reset
	@echo "✅ Setup complete!"

stop:
	$(COMPOSE_CMD) stop $(filter-out $@,$(MAKECMDGOALS))

start:
	$(COMPOSE_CMD) up -d $(filter-out $@,$(MAKECMDGOALS))

restart:
	$(COMPOSE_CMD) restart $(filter-out $@,$(MAKECMDGOALS))

logs:
	$(COMPOSE_CMD) logs -f $(filter-out $@,$(MAKECMDGOALS))

shell:
	$(EXEC_CMD) bash

console:
	$(EXEC_CMD) bundle exec rails console

format:
	$(EXEC_CMD) bundle exec rubocop --autocorrect-all

test:
	$(COMPOSE_CMD) exec app bundle exec bash -c "export RAILS_ENV=test && rspec --format documentation $(FILE)"

test_fast:
	$(COMPOSE_CMD) exec app bundle exec bash -c "export RAILS_ENV=test && rspec --format documentation --fail-fast $(FILE)"

migrate:
	$(EXEC_CMD) bundle exec rails db:migrate

db_reset:
	$(EXEC_CMD) bundle exec rails db:drop db:create db:prepare

clean:
	$(COMPOSE_CMD) down -v

clean_volumes:
	docker volume rm -f $(PROJECT_NAME)_localstack_data $(PROJECT_NAME)_db_data

%:
	@:
