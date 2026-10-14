# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, GitHub Copilot,
and others) when working with code in this repository.

## What this repository is

PlanningAlerts is a Ruby on Rails application that collects Australian local
government planning applications and emails people about the ones near an
address they care about. It also serves a public API, takes comments on
applications and forwards them to the responsible council, and runs an admin
backend for staff.

This repository is only the web application. The scrapers that actually collect
the data live in the `planningalerts-scrapers` organisation and run on
[morph.io](https://morph.io/); this app pulls their output over the morph API.
So when data looks wrong, the cause is often a scraper rather than anything
here.

Rails 7.1 on Ruby 3.3.4, PostgreSQL with PostGIS, Elasticsearch via Searchkick,
Redis, and Sidekiq. Note that `config/application.rb` runs
`config.load_defaults 7.0`, not 7.1, so Rails 7.1 framework defaults are opt-in
through `config/initializers/new_framework_defaults_7_1.rb`.

## Contributing, branches and commits

There is **no `CONTRIBUTING.md` and no pull request template in this
repository**. Both are inherited from
[`openaustralia/.github`](https://github.com/openaustralia/.github), and that is
the authority on how to work here. Read
[`.github/CONTRIBUTING.md`](https://github.com/openaustralia/.github/blob/main/.github/CONTRIBUTING.md)
there before opening anything. The parts most easily got wrong:

- Branch off `main` using [Conventional Branch](https://conventionalbranch.org/#summary)
  with the issue number: `feature/123-add-postcode-search`,
  `bugfix/890-fix-pagination`, `doc/7391-clarify-setup-steps`.
- Open the pull request as a **draft** and fill in the inherited template. Take
  it out of draft only once the checks pass. Assign it to yourself.
- Sign off every commit with the Developer Certificate of Origin
  (`git commit -s`). A human, not an agent, makes that sign-off, because it is a
  legal certification only a person can give.
- Disclose AI assistance in two places: an `Assisted-by: <agent>:<model-id>`
  trailer on each commit, alongside `Signed-off-by`, and a note in the pull
  request description. Report the model actually used, not a remembered default.

Be aware of one inconsistency: the `## Contributing` section of `README.md`
still describes an older fork-and-topic-branch flow. The org guide supersedes
it. Follow the org guide, and do not silently "fix" the README as a side effect
of unrelated work.

`.github/CODEOWNERS` requests review from `@openaustralia/team-planningalerts`.
A team without access to the repository is silently ignored by GitHub rather
than erroring, which is what [#2135](https://github.com/openaustralia/planningalerts/pull/2135)
fixed by removing a second team that held access to nothing. Do not add teams
there speculatively, and check the team really has access.

## Docker development environment

One stack, defined in `.devcontainer/compose.yaml`, serves every way of working: `make`, plain `docker compose`
(through the root `compose.yaml`), and the dev container in VS Code, RubyMine, Codespaces or
`devcontainer up --workspace-folder .`. They all share the same containers and data.

```
make up           # everything, including the app at http://localhost:3000, once it's ready
make services-up  # everything except `web`, for running Rails on the host
make status       # each container's health and host ports
make logs         # follow the logs (SERVICE=<name> for one container)
make shell        # a shell in the app container, or a fresh one if it has stopped
make down         # stop and remove the containers, keeping the data
make clean        # also remove built images and dependencies, so the next start rebuilds; keeps the data
make clobber      # also remove the data, and prune unused Docker images and cache machine-wide
```

`make up` and `make services-up` return once every service passes its healthcheck. Run `make` for the full list.
A start that takes longer than `START_LIMIT` (in `.devcontainer/compose.yaml`) counts as failed, and stops loudly on purpose;
see "If the app won't start" in the README.

Everything normally runs in Docker; running Rails on the host against `make services-up` is mainly for single-step
debugging in an IDE (see the README). The `web` container runs `bin/setup`, which installs gems and prepares the
database, before `bin/dev` starts Rails, Tailwind and Sidekiq. Plain `docker compose run web ...` commands work as
before. Each worktree needs at least 2GB of free memory, more for the browser-based tests.

`db/seeds.rb` creates `admin@example.com` (confirm it via the mailcatcher
inbox at <http://localhost:1080>) and one authority with one application. The
admin role is not seeded; add it in a console with
`User.first.add_role(:admin)`.

**Every service is pinned to `platform: linux/amd64`.** This is not incidental:
Sorbet has no `linux/arm64` build ([sorbet#4119](https://github.com/sorbet/sorbet/issues/4119)),
and neither does the PostGIS image. On Apple Silicon you must switch on "Use
Rosetta for x86/amd64 emulation on Apple Silicon" in Docker Desktop or the
containers will not start. Do not "helpfully" remove those `platform` keys.

Service versions in `.devcontainer/compose.yaml` deliberately match production:
PostGIS 15-3.4, Redis 6.2.6, Elasticsearch 7.17.7. Keep them matched when you
change one.

### Port clashes

| Variable           | Default | Publishes                                                                   |
|--------------------|---------|-----------------------------------------------------------------------------|
| `WEB_PORT`         | 3000    | the app. Mailer links and the API example URLs follow it                    |
| `POSTGRES_PORT`    | 15432   | PostGIS. Rails on the host needs `DB_HOST=localhost` and `DB_PORT` to match |
| `POSTFIX_PORT`     | 2525    | postfix, for testing incoming email                                         |
| `MAILCATCHER_PORT` | 1080    | the mailcatcher inbox                                                       |

Put overrides in `.env` at the repo root, which is gitignored, with different values in each worktree. Compose reads
it however you start the stack. Containers and data are named `planningalerts` (`name:` in `compose.yaml`), so a second checkout of
this repo, such as a worktree, shares them unless its `.env` also sets its own `COMPOSE_PROJECT_NAME`. For
host-side commands to see the same values, put `dotenv` in a gitignored `.envrc` if you use direnv, or
run `set -a; . ./.env; set +a`. Services you rarely need from the host get a random port, which `make status` shows.
To see what holds a port, use `ss -ltnp | grep 3306` (Linux) or `lsof -iTCP:3306 -sTCP:LISTEN` (macOS); a database
server installed on the host is the usual culprit.

The repository is bind-mounted at `/app`, so dotenv and foreman inside the container load `.env` as well. That's how
`WEB_PORT` reaches `config/environments/development.rb` and `api_port` in `app/helpers/applications_helper.rb`.
`.env` is also the place for local secrets; shareable app config goes in the committed `.env.development`.

## Things that reference each other

Nothing checks these for you, so keep them consistent by hand:

- Service versions appear in both `.devcontainer/compose.yaml` and
  `.github/workflows/rubyonrails.yml`, and both claim to match production.
  Changing one means changing the other.
- The four Sorbet-related pins in the `Gemfile` described above.
- Maizzle sources, their compiled `.erb` output, and the `exclude` list in
  `.erb-lint.yml`.
- The Postgres password in `.devcontainer/compose.yaml` and `config/database.yml`.
- `.ruby-version` and the Ruby actually installed on the servers, which is
  managed from the separate `oaf/infrastructure` Ansible repository you probably
  cannot see from here. Treat the mechanism described in `README.md` as history
  rather than instructions, since that runbook predates the current blue/green
  deploy; confirm how Ruby versions reach the servers today before relying on
  it.

## Conventions specific to this org

- **Non-partisan, strictly.** Nothing in the codebase or in user-facing copy
  should imply endorsement or criticism of any party, candidate or position.
  Report what the data says and let people draw conclusions.
- Australian English throughout, in code, copy and comments.
- No em dashes. Use a hyphen, a comma or a full stop.
- Say "people", not "users" or "citizens", in anything a person will read.
- Never invent a figure, quote, citation or URL, in code, comments or copy.
- Follow the Australian Privacy Principles. Use fictional placeholders in
  examples, factories and fixtures, never real personal details. This codebase
  holds real names, email addresses and comments from members of the public;
  `doc/data_retention_policy.md` sets out what is kept and for how long, and
  `doc/using_production_data_locally.md` covers working with a production dump.
- Match the existing spelling of the product rather than normalising it. This
  codebase and the site render it as "PlanningAlerts", one word, while OAF's
  org-level style guide writes the service as "Planning Alerts". Follow what
  the surrounding file already does and leave the discrepancy alone; renaming
  it is a deliberate content decision, not a tidy-up.
- Do not invent variations on the names of OAF's other services. They are Right
  to Know, They Vote for You, OpenAustralia.org.au and morph.io.
