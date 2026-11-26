.PHONY: help setup up services-up down clean clean-data clobber status logs shell test lint typecheck generate-rbi clobber-rbi clean-rbi console

# Runs a command in the web container, or in a fresh one if it has stopped
in_web = if [ -n "$$(docker compose ps -q --status running web)" ]; then docker compose exec web $(1); else docker compose run --rm web $(1); fi

help: ## Show this help (the default target)
	@grep -hE '^[a-zA-Z0-9_.-]+:.*## ' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*## "}; {printf "  %-12s %s\n", $$1, $$2}'

# For running Rails on the host. mise is preferred, rbenv works too; both read .ruby-version (mise via mise.toml).
# bin/setup can't install Ruby itself, as it needs Ruby to run. It reaches PostGIS on the port compose published.
# GCC 12 and later reject the pinned prism gem's C, so that warning is kept a warning (see #2293).
# Then it checks the Sentry CLI that deploys use to record releases: sentry, or sentry-cli (v3) as a fallback
# (lib/capistrano/tasks/sentry.rake). It's installed once per machine, not per project, so it isn't in mise.toml.
# Logging in fails inside this repo, where .sentryclirc's EU url sends it to the wrong host, so it's done from ~.
setup: services-up ## Install Ruby (with mise or rbenv), gems and the database to run Rails on the host, and check the Sentry CLI for deploys
	@export DB_HOST=localhost DB_PORT=$$(docker compose port postgres 5432 | sed 's/.*://'); \
	if cc -v 2>&1 | grep -q '^gcc version'; then export CFLAGS="$${CFLAGS:-} -Wno-error=dangling-pointer"; fi; \
	if command -v mise >/dev/null; then mise trust && mise install && mise exec -- bin/setup; \
	elif command -v rbenv >/dev/null; then rbenv install --skip-existing && rbenv exec ruby bin/setup; \
	else echo "Install mise (https://mise.jdx.dev) or rbenv first" >&2; exit 1; fi
	@if sentry auth status >/dev/null 2>&1 || sentry-cli info >/dev/null 2>&1; then :; \
	elif ! command -v sentry >/dev/null && command -v sentry-cli >/dev/null; then \
	  echo "WARNING: the Sentry CLI (sentry-cli) is not logged in, so deploys won't be recorded in Sentry." >&2; \
	  echo "Log in once, from outside this repo: cd ~ && sentry-cli login" >&2; \
	elif ! command -v sentry >/dev/null; then \
	  echo "WARNING: the Sentry CLI (sentry-cli) is not installed, so deploys won't be recorded in Sentry." >&2; \
	  echo "Install it from https://docs.sentry.io/cli/installation/" >&2; \
	  echo "then log in once, from outside this repo: cd ~ && sentry-cli login" >&2; \
	else \
	  echo "WARNING: the Sentry CLI is not logged in, so deploys won't be recorded in Sentry." >&2; \
	  echo "Log in once, from outside this repo: cd ~ && sentry auth" >&2; \
	fi

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
	docker volume rm --force "$${p}_bundle" && \
	{ [ -z "$$vsc" ] || docker rmi --force $$vsc; }
	git clean -fdX -- log tmp coverage # gitignored files only, so tracked placeholders stay
# For a checkout you're finished with, or whose databases you want to start again. Touches only this project.
clean-data: clean ## Also remove this checkout's data (databases, Elasticsearch, Redis), leaving other projects alone
	docker compose down --volumes
# Reaches past this checkout, for after switching branches or changing dependencies. Other projects lose only
# download and build time, as volumes (where their databases live) are never pruned.
clobber: clean-data ## Also remove all stopped containers, unused images and build cache machine-wide
	@echo "Pruning stopped containers, unused images and build cache from ALL projects (volumes are kept)"
	docker system prune --all --force
status: ## Show each container's health, the host ports it's published on, and where to browse
	@docker compose ps -a --format 'table {{.Service}}\t{{.Status}}\t{{.Ports}}'
	@echo; port() { docker compose port $$1 $$2 2>/dev/null | sed 's/.*://'; }; \
	p=$$(port web 3000); [ -z "$$p" ] || echo "Web:         http://www.pa.org.localhost:$$p/ (users: admin@example.com and jane@example.com, password: password, from db/seeds.rb)"; \
	p=$$(port mailcatcher 1080); [ -z "$$p" ] || echo "Mailcatcher: http://mailcatcher.localhost:$$p/"
logs: ## Follow the logs of every container (or SERVICE=web for one)
	docker compose logs -f $(SERVICE)
shell: ## Open a shell in the web container, or in a fresh one if it has stopped (e.g. after a failed start)
	@$(call in_web,fish)
# The same checks as CI; see "Commands" in AGENTS.md
test: ## Run the specs as CI does, after resetting the test database (ARGS=spec/models/alert_spec.rb:42 to narrow)
	@$(call in_web,bin/rails db:test:prepare tailwindcss:build)
	@$(call in_web,bin/rspec $(ARGS))
lint: ## Run RuboCop, erb_lint and Brakeman as CI does (ARGS=<paths> for RuboCop on just those)
	@$(call in_web,$(if $(ARGS),bin/rubocop $(ARGS),bin/rake ci:lint))
typecheck: ## Run Sorbet and the tapioca checks as CI does (with CI=true, so Rails eager loads as it does there)
	@$(call in_web,env CI=true bin/rake ci:type)
# CI=true makes config/environments/test.rb eager load, so the test run sees classes a normal run does not.
# `env` carries it through both `docker compose exec` and `run`. Tapioca loads the app and checks its migrations, so
# the databases are prepared first, as `make test` does for the test one (a fresh worktree has none).
generate-rbi: ## Regenerate every Sorbet RBI in the one order that works: gems, then DSL, then DSL as CI runs it
	@$(call in_web,bin/rails db:prepare)
	@$(call in_web,bin/tapioca gem)
	@$(call in_web,bin/tapioca dsl)
	@$(call in_web,env CI=true bin/tapioca dsl --environment=test)
clobber-rbi: ## Delete every generated RBI (sorbet/rbi/gems and dsl), keeping the hand-written shims and todo.rbi, to force regeneration
	@rm -rf sorbet/rbi/gems sorbet/rbi/dsl
clean-rbi: ## Delete only the gem RBIs (sorbet/rbi/gems) for versions not in Gemfile.lock (PREVIEW=1 to only list them)
	@test -r Gemfile.lock || { echo "Gemfile.lock not found" >&2; exit 1; }
	@for f in sorbet/rbi/gems/*.rbi; do \
	  [ -e "$$f" ] || continue; \
	  b=$$(basename "$$f" .rbi); n=$${b%%@*}; v=$${b#*@}; v=$${v%%-*}; \
	  grep -Eq "^    $$n \($$v[-)]" Gemfile.lock || $(if $(PREVIEW),echo,rm -v) "$$f"; \
	done
console: ## Open a Rails console in the web container
	@$(call in_web,bin/rails console)
