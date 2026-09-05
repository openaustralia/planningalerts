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

## Getting a working environment

Everything runs through Docker Compose. There is no supported way to run the app
against a local database and Redis without it.

```sh
docker compose run web bin/rake db:setup   # first time, also triggers a build
docker compose up                          # then http://localhost:3000
```

`db/seeds.rb` creates `admin@example.com` (confirm it via the mailcatcher
inbox at <http://localhost:1080>) and one authority with one application. The
admin role is not seeded; add it in a console with
`User.first.add_role(:admin)`.

**Every service is pinned to `platform: linux/amd64`.** This is not incidental:
Sorbet has no `linux/arm64` build ([sorbet#4119](https://github.com/sorbet/sorbet/issues/4119)),
and neither does the PostGIS image. On Apple Silicon you must switch on "Use
Rosetta for x86/amd64 emulation on Apple Silicon" in Docker Desktop or the
containers will not start. Do not "helpfully" remove those `platform` keys.

Service versions in `docker-compose.yml` deliberately match production:
PostGIS 15-3.3, Redis 6.2, Elasticsearch 7.17.7. Keep them matched when you
change one.

## Commands

CI (`.github/workflows/rubyonrails.yml`) has exactly three gates. Run these
three, and nothing less, before taking a pull request out of draft:

```sh
docker compose run web bin/rake            # the RSpec suite
docker compose run web bin/rake ci:type    # Sorbet, plus tapioca --verify checks
docker compose run web bin/rake ci:lint    # RuboCop, erb_lint, Brakeman -w2
```

`bin/rake ci:all` looks like the obvious shortcut and is not. Its description
says "Run everything that gets run on CI", but inside `namespace :ci` there is
no `ci:test` task, so the `test` prerequisite falls through to Rails' top-level
minitest task. This repository has no `test/` directory, so that step silently
does nothing and `ci:all` never runs a single spec. Its prerequisites resolve to
`["test", "ci:type", "ci:lint"]`, which you can confirm with
`Rake::Task["ci:all"].prerequisite_tasks`.

To run a subset of specs, go through `bin/rspec`:

```sh
docker compose run web bin/rake tailwindcss:build          # required first, see below
docker compose run web bin/rspec spec/models/alert_spec.rb
docker compose run web bin/rspec spec/models/alert_spec.rb:42
docker compose run web bin/rspec spec/features             # slow, browser-driven
```

**`bin/rspec` needs `bin/rake tailwindcss:build` first, or nearly every spec
fails on a missing asset.** The shared head partial
`app/views/application/_html_head.html.erb` calls
`stylesheet_link_tag "tailwind"`, and `app/assets/builds/tailwind.css` is
generated, gitignored, and absent from a fresh checkout. Rake builds it for you
through a chain that is easy to miss: `default` depends on `spec`, `spec`
depends on `spec:prepare`, rspec-rails' `spec:prepare` invokes `test:prepare`,
and `tailwindcss-rails` enhances `test:prepare` with `tailwindcss:build`.
Invoking `bin/rspec` directly skips that whole chain. This is why CI passes on
`bin/rake` while a bare `bin/rspec` fails.

`docker compose run web bin/guard` gives you a watcher that reruns affected
specs and RuboCop on save.

## Sorbet is not optional here

**All 158 `.rb` files in `app/` and `lib/` carry `# typed: strict`.** There are
no exceptions, so a new file without a sigil and full signatures will fail
`bin/rake ci:type`. In practice that means every new class gets
`# typed: strict`, `# frozen_string_literal: true`, `extend T::Sig`, and a
`sig` on every method, with instance variables wrapped in `T.let` at
assignment. `app/components/button_component.rb` is a representative example.
`sorbet/config` excludes `spec/`, `db/` and `vendor/`, so specs are untyped.

RBI files are managed with Shopify's tapioca. **Never use
`bundle exec srb rbi`.**

```sh
docker compose run web bin/srb                              # type check
docker compose run web bin/tapioca gem                      # gem RBIs
docker compose run web bin/tapioca dsl
docker compose run web bin/tapioca dsl --environment=test    # what CI verifies
```

`ci:type` runs `--verify` variants of all three plus `check-shims`, so
out-of-date RBIs fail CI even when the code type checks.

`sorbet/config` also ignores `.claude/`, because agent worktrees nest a full
checkout inside the repository and Sorbet would otherwise load every RBI twice.
If you set up worktrees somewhere else, expect duplicate-definition errors and
add that path too.

### The version pins are one interlocking constraint

The `Gemfile` pins `zeitwerk ~> 2.6.0`, `tapioca ~> 0.15.1`, `sorbet < 6.0` and
`sorbet-runtime < 0.6`, each with a `TODO` about removing it. Treat them as a
single unit rather than four independent pins. tapioca 0.15.1 crashes on
zeitwerk >= 2.7, and tapioca 0.16 to 0.19 work with zeitwerk 2.8 but hit a
require-hooks double-load bug that breaks `bin/tapioca dsl` instead. The
combination in the `Gemfile` is the only fully clean one. Bumping any one of
them alone will break RBI generation, so do not let a routine dependency update
touch them without running `bin/rake ci:type` and reading the comments above
each pin.

The `elasticsearch` gem is pinned to `~> 7` for a different reason: it cannot
move ahead of the 7.17 server running in production.

## Architecture

Two data pipelines carry most of the value, and both are Sidekiq jobs fanned out
over 24 hours rather than run in one burst. `QueueUpJobsOverTimeService` does the
spreading, so a job that "runs daily" per `config/cron.yml` is really thousands
of jobs trickling through the day.

**Importing applications.** `QueueUpImportApplicationsJob` enqueues one
`ImportApplicationsJob` per *active* authority. `ImportApplicationsService`
queries the morph.io API for that authority's scraper output, and
`CreateOrUpdateApplicationService` writes the results.

**Sending alerts.** `QueueUpProcessAlertsJob` enqueues a `ProcessAlertJob` for
every active alert, shuffled so one authority's alerts do not all land together.
`ProcessAlertService` gathers both nearby applications and new comments for the
alert's geocoded point and sends a single `AlertMailer.alert`;
`ProcessAlertAndRecordStatsService` wraps it to record stats.

Periodic jobs are declared in `config/cron.yml` and run by `sidekiq-cron`, which
means once per cluster. Use ordinary cron only for work that must run on every
machine, and note that `config.time_zone` is `"UTC"` while every cron entry is
written in `Australia/Sydney`.

### Domain shapes worth knowing before you edit a model

- **`Application` and `ApplicationVersion`.** An `Application` is the stable
  record; its mutable detail lives in versions, ordered newest first, with
  exactly one flagged `current: true` and exposed as `current_version`. Reach
  for `current_version` rather than assuming fields sit on `Application`.
- **`Application#description` and `#address` are overridden readers.** Both
  call a normalising class method on `attributes[...]`, so the database value
  and the value you read back differ. Do not bypass them with
  `read_attribute`.
- **Spatial queries use PostGIS directly.** `Alert` reaches for
  `ST_DWithin(lonlat, ?, ?)` in raw SQL against the `lonlat` column, while
  Searchkick indexes a separate `location` hash built from `lat`/`lng`.
  `Application#search_data` explicitly deletes `:lonlat` because Elasticsearch
  cannot index the encoded geometry.
- **`Application.policy_class` returns `ApplicationsPolicy`, plural.** Pundit
  would infer `ApplicationPolicy`, which is already the name of the base policy
  class. Authorisation is Pundit for the app and `rolify` for roles.
- **`Alert` geocodes itself in a `before_validation` hook** through
  `GoogleGeocodeService`, using a credential from
  `Rails.application.credentials`. Creating an `Alert` in a spec without a
  stubbed geocoder will try to reach the network.

Service objects follow one convention consistently: a `self.call(...)` class
method that constructs the object and calls a private-ish instance `call`. Match
it in new services rather than inventing a variant.

Two independent switching systems coexist and are easy to confuse. `flipper`
(Redis-backed, with `flipper-ui` mounted) is for feature flags. `split` is for
A/B tests. Pick deliberately.

Error reporting is Sentry, following the canonical configuration in the
infrastructure repo's `docs/monitoring.md` (the Honeybadger transition in
[#2049](https://github.com/openaustralia/planningalerts/issues/2049) is
complete and the gem is gone).

### Front end

Views are ERB with Tailwind, and reusable markup goes in `app/components` as
ViewComponents. Two constraints on those:

- **ViewComponent is 4.12, so `initialize` must call `super()` with explicit
  empty parens.** A bare `super` forwards the component's keyword arguments to
  `ViewComponent::Base#initialize` and raises `ArgumentError`.
- Colours and sizes are validated by `case` statements that `raise` on anything
  unexpected, rather than by silently falling back. Adding a variant means
  adding a branch.

`doc/visual-design.md` holds the design intent and an inventory of every
user-facing page. `doc/principles.md` holds the product principles, and "do
less" at the top of that list is meant literally.

### Emails are generated, not hand-written

Email templates are authored in Maizzle under `maizzle/src/templates` and
compiled into the Rails tree. **Editing the compiled `.erb` is wasted work,
because the next `npm run dev` overwrites it.** The generated files are listed
in the `exclude` block of `.erb-lint.yml`, which is the reliable way to tell
which ones they are:

- `app/views/alert_mailer/alert.html.erb`
- `app/views/devise/mailer/confirmation_instructions.html.erb`
- `app/views/devise/mailer/reset_password_instructions.html.erb`
- `app/views/devise/mailer/unlock_instructions.html.erb`
- `app/views/users/activation_mailer/notify.html.erb`

To work on them, run `cd maizzle && npm run dev production` and preview at
<http://localhost:3000/rails/mailers/>. All development mail goes to mailcatcher
at <http://localhost:1080>.

## The test harness makes some decisions for you

`spec/spec_helper.rb` configures several things globally that change how specs
behave, and each one has bitten someone:

- **`Sidekiq::Testing.inline!`** means enqueuing a job runs it immediately.
  Specs that expect asynchrony will not see it.
- **`Searchkick.disable_callbacks`** avoids needing Elasticsearch locally, so
  nothing is indexed. Search behaviour cannot be asserted through the normal
  path.
- **`Rack::Attack.enabled = false`**, because specs log in often enough to trip
  throttling. Rate limiting cannot be tested as configured.
- **VCR records with `record: :new_episodes`.** A spec that makes an
  unmatched request appends to the cassette in
  `spec/fixtures/vcr_cassettes` and passes. Check `git diff` on cassettes
  before committing, because a silently grown cassette usually means a real
  request escaped.
- **Flipper uses a pstore adapter** at `tmp/flipper.pstore`, deleted before
  every example, chosen over the in-memory adapter so flags survive into
  Capybara `js: true` specs.
- `ActionMailer::Base.deliveries` is cleared before every example as a
  workaround for feature specs not clearing it properly.

Feature specs run headless Selenium and additionally assert accessibility with
axe (`axe-core-rspec`) and take Percy visual snapshots. Percy needs
`PERCY_TOKEN`, which CI supplies; locally the snapshot calls are inert. Factories
are FactoryBot, all declared in a single `spec/factories.rb`.

## Linting quirks

RuboCop is the authority on style; do not apply personal preferences over it.
Some settings in `.rubocop.yml` exist for reasons worth knowing:

- **`Naming/BlockForwarding: explicit`** is deliberately enabled because Ruby's
  anonymous block forwarding is not compatible with Sorbet. Write `&block`.
- Double-quoted strings are enforced, including in multi-line strings.
- `Layout/LineLength` and the whole `Metrics/*` family are disabled, with
  `TODO`s about re-enabling. Long methods are not a lint failure, which is not
  the same as being encouraged.
- `bin/*`, `config/*`, `db/migrate/*`, `vendor/**/*` and `maizzle/**/*` are
  excluded entirely, so `config/application.rb` is `# typed: false` and
  unformatted on purpose.

`bin/erblint --lint-all` covers ERB and excludes the Maizzle-generated files
above plus the overridden administrate templates under
`app/views/admin/application/`, which are kept close to upstream deliberately.

Brakeman runs as `-q -w2` with agreed exceptions recorded in
`config/brakeman.ignore`. Add to that file with `brakeman -I` rather than
lowering the warning level.

## Deployment

Capistrano, from `main`, to two EC2 web servers:

```sh
bundle exec cap production deploy
bundle exec cap staging --set branch=my-branch deploy
```

Deploys record a release in Sentry through a Capistrano hook that shells out to
the Sentry CLI on your machine (`sentry`, or the legacy `sentry-cli`). The
committed `.sentryclirc` holds only non-secret defaults; **credentials come
from `sentry auth` (v4) or `~/.sentryclirc` (v3) and must never be
committed.** A missing or unauthenticated CLI prints a warning and skips the
release rather than failing the deploy, so a quiet deploy is not proof it
worked.

The Ruby upgrade runbook in `README.md` is explicitly marked out of date; it
predates the current blue/green setup. Treat it as history.

## Things that reference each other

Nothing checks these for you, so keep them consistent by hand:

- Service versions appear in both `docker-compose.yml` and
  `.github/workflows/rubyonrails.yml`, and both claim to match production.
  Changing one means changing the other.
- The four Sorbet-related pins in the `Gemfile` described above.
- Maizzle sources, their compiled `.erb` output, and the `exclude` list in
  `.erb-lint.yml`.
- The Postgres password in `docker-compose.yml` and `config/database.yml`.
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
