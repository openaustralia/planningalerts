.PHONY: help up services-up down clean clobber status logs shell test lint typecheck console

# Runs a command in the web container, or in a fresh one if it has stopped
in_web = if [ -n "$$(docker compose ps -q --status running web)" ]; then docker compose exec web $(1); else docker compose run --rm web $(1); fi

help: ## Show this help (the default target)
	@grep -hE '^[a-zA-Z0-9_.-]+:.*## ' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*## "}; {printf "  %-12s %s\n", $$1, $$2}'

# The stack is defined in .devcontainer/compose.yaml (see "Getting a working environment" in AGENTS.md).
# --wait returns once every service passes its healthcheck, so the next command can use them straight away.
up: ## Start everything, including the app at http://localhost:3000, once it's ready
	docker compose up --build --wait -d
services-up: ## Start everything except web, for running Rails on the host
	docker compose up --build --wait -d postgres redis elasticsearch mailcatcher postfix
down: ## Stop and remove the containers, keeping the data
	docker compose down --remove-orphans
# Everything this checkout built, so the next `make up` rebuilds from scratch. The data is kept.
# VS Code's dev container builds its own images on top of compose's. Only this project's containers say which
# they are, so they're noted before `down` removes them.
clean: ## Remove containers, built images (VS Code's too), gems, logs and tmp, keeping the data
	p=$$(docker compose config | sed -n 's/^name: //p'); \
	vsc=$$(docker ps -a --filter "label=com.docker.compose.project=$$p" --format '{{.Image}}' | grep '^vsc-' | sort -u); \
	docker compose down --remove-orphans --rmi local && \
	docker volume rm --force "$${p}_gem_cache" && \
	{ [ -z "$$vsc" ] || docker rmi --force $$vsc; }
	git clean -fdX -- log tmp coverage # gitignored files only, so tracked placeholders stay
# Reaches past this checkout, for after switching branches or changing dependencies. Other projects lose only
# download and build time, as volumes (where their databases live) are never pruned.
clobber: clean ## Also remove the data, then all stopped containers, unused images and build cache machine-wide
	docker compose down --volumes
	@echo "Pruning stopped containers, unused images and build cache from ALL projects (volumes are kept)"
	docker system prune --all --force
status: ## Show each container's health and the host ports it's published on
	@docker compose ps -a --format 'table {{.Service}}\t{{.Status}}\t{{.Ports}}'
logs: ## Follow the logs of every container (or SERVICE=web for one)
	docker compose logs -f $(SERVICE)
shell: ## Open a shell in the web container, or in a fresh one if it has stopped (e.g. after a failed start)
	@$(call in_web,fish)
# The same checks as CI; see "Commands" in AGENTS.md
test: ## Run the specs as CI does, after resetting the test database (ARGS=spec/models/alert_spec.rb:42 to narrow)
	@$(call in_web,bash -c 'bin/rails db:test:prepare tailwindcss:build && bin/rspec $(ARGS)')
lint: ## Run RuboCop, erb_lint and Brakeman as CI does (ARGS=<paths> for RuboCop on just those)
	@$(call in_web,$(if $(ARGS),bin/rubocop $(ARGS),bin/rake ci:lint))
typecheck: ## Run Sorbet and the tapioca checks as CI does
	@$(call in_web,bin/rake ci:type)
console: ## Open a Rails console in the web container
	@$(call in_web,bin/rails console)
