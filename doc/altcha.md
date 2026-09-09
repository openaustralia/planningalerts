# ALTCHA

[ALTCHA](https://altcha.org) is a self-hosted, MIT-licensed alternative to a
captcha. Instead of asking somebody to identify traffic lights, it asks their
browser to do a small amount of arithmetic. That costs a person a moment and
costs a bot enough, repeated thousands of times, to make bulk submissions
expensive. Nothing is sent to a third party, which is the main reason we chose
it over reCAPTCHA.

It protects the public forms that create accounts or send email: sign up (both
routes), password reset, resend confirmation, account activation, and the
contact form. Comments, alerts and abuse reports already need somebody to be
signed in, so they are not covered.

See [#1682](https://github.com/openaustralia/planningalerts/issues/1682).

## How it fits together

1. `AltchaWidgetComponent` renders `<altcha-widget>` on the form.
2. The widget fetches a challenge from `GET /altcha/challenge`
   (`AltchaChallengesController`, built by `CreateAltchaChallengeService`).
3. The browser solves it and puts the answer in a hidden `altcha` field.
4. The controller calls `altcha_ok?` from `AltchaProtectable`, which runs
   `VerifyAltchaSolutionService`.

The two secrets are derived from `secret_key_base` by `AltchaSecretsService`,
so there is no new credential to add and the check is not silently absent in
test.

The gem verifies that an answer is correct and unexpired but has no idea whether
it has been used before. `AltchaSolution` is ours: one row per accepted answer,
with a unique index, swept daily by `DeleteExpiredAltchaSolutionsJob`.

## The two feature flags

`altcha` shows the widget and checks the answer. `altcha_enforce` decides
whether a failed check actually rejects. With `altcha` on and
`altcha_enforce` off we are in monitor mode: the outcome is counted in Sentry
under `altcha.checks` and the form goes through anyway.

**Never put a `percentage_of_time` gate on either flag.** A form is rendered on
one request and checked on another, and a gate that answers differently each
time would reject people whose form was rendered without a widget. A percentage
rollout must use `percentage_of_actors`, which hashes a stable id: the signed
in `User`, or a `Visitor` keyed on a value kept in the session.

The `admins` group is no help for trying this out, because every protected form
is one only logged-out people ever see.

Suggested order:

1. `altcha` on, `altcha_enforce` off. Watch `altcha.checks` in Sentry.
   The share of `missing` outcomes is roughly the share of people who would be
   turned away by enforcing, mostly because JavaScript did not run.
2. Decide whether that number is acceptable. This is a product decision, not a
   technical one: enforcing locks out everybody without JavaScript.
3. `altcha_enforce` on, then `altcha` to `percentage_of_actors 50`. That
   starts the contact form comparison, where half of people see ALTCHA and half
   see reCAPTCHA, stickily.

The contact form has no monitor mode. It is the one form that already had a
check, and gathering monitor data there would mean showing two captchas at once.
It stays on reCAPTCHA until `altcha_enforce` is on, so it is never unprotected.

## The vendored widget

`app/assets/javascripts/altcha.js` is committed rather than loaded from a CDN,
unlike the other third-party scripts in `app/views/application/_html_head.html.erb`.
Those all degrade to something cosmetic and are guarded by `runWithFallback`. A
missing ALTCHA widget in enforce mode stops somebody signing up or asking us for
help, so it is served from our own origin. Self-hosting is also the reason to
prefer ALTCHA in the first place: no third party sees who is filling in our
forms.

| | |
| --- | --- |
| Package | [`altcha`](https://www.npmjs.com/package/altcha) 3.2.2, MIT |
| File | `dist/main/altcha.umd.min.cjs` |
| SHA-256 | `1d07680eee66c3b591c6638640f7bf763112bf88d7223a331f7d2b49f0ce4968` |

The **UMD** build, deliberately. The ESM build would need `type="module"`, and
production runs `config.assets.js_compressor = :terser`, which is not told to
expect module syntax. The UMD build is a plain script. It also builds its Web
Worker from a Blob, so there is no companion file for Sprockets' digested
filenames to break.

Dependabot does not watch this file, since there is no npm ecosystem at the
repository root. To update it:

```sh
curl -sS -o app/assets/javascripts/altcha.js \
  -L "https://cdn.jsdelivr.net/npm/altcha@<version>/dist/main/altcha.umd.min.cjs"
```

Then check the widget attribute names have not changed (`challenge`, `name`,
`auto`, `hidelogo`, `hidefooter`, `test`) and run the specs. Version 3
renamed `challengeurl` to `challenge`, and getting that wrong is silent: the
widget renders nothing and every submission looks like a failure.

## Testing

`spec/support/altcha_helpers.rb` solves a challenge in Ruby, so the whole thing
is testable without a browser. Stub the cost down first:

```ruby
stub_const("CreateAltchaChallengeService::COST", 100)
```

We deliberately never set the widget's own `test` attribute. It makes the widget
report success while submitting a payload with no challenge in it, which the
server can never verify, so it could not prove anything. `spec/features/altcha_spec.rb`
gets its determinism instead by stubbing the cost down and waiting for the
widget to fill the hidden field.

## Things to check before enforcing

- **Time the proof of work on a low-powered phone.** `COST` and
  `COUNTER_RANGE` in `CreateAltchaChallengeService` decide how long people
  wait. Too high and signing up feels broken.
- **Confirm Cloudflare is not caching `/altcha/challenge`.** The controller
  sends `Cache-Control: no-store`, but a cache rule could override it. A cached
  challenge fails as "almost everybody is rejected as a replay".
- **Check what ALTCHA offers somebody who cannot use the widget.** It advertises
  an image and audio fallback, but on some configurations that belongs to the
  paid Sentinel product rather than the self-hosted widget. If the self-hosted
  widget has no accessible alternative, the accessible path is the contact link
  in the component's `<noscript>`, and we should say so plainly.

The Rack::Attack throttle on `/altcha/challenge` cannot be tested:
`spec/spec_helper.rb` sets `Rack::Attack.enabled = false`.
