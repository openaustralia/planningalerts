# typed: strict
# frozen_string_literal: true

# Basic auth for the idle environment, www-idle.planningalerts.org.au, so bots
# and casual visitors can't reach it while it waits for cutover. See #2239.
#
# Done in the app rather than as a Cloudflare WAF rule, which would collide with
# the terraform import of that zone's http_request_firewall_custom ruleset
# (Cloudflare allows only one entrypoint ruleset per zone per phase), or at the
# ALB, which would mean paying for Cognito.
#
# Trying it out in development
# ----------------------------
#
# There is no development credentials key, so use the environment. Put these in
# .env, which is gitignored. Not .env.development, which is committed:
#
#   IDLE_BASIC_AUTH_USERNAME=idle
#   IDLE_BASIC_AUTH_PASSWORD=some-local-password
#
# dotenv reads .env at boot, so run `docker compose restart web` after editing
# it. Docker Compose reads the same file for its own variable substitution, so
# avoid a $ in the password.
#
# You need a host starting with www-idle. Use www-idle.localhost, which needs no
# /etc/hosts entry because Rails allows any .localhost subdomain in development.
# Don't fake www-idle.planningalerts.org.au instead: this runs ahead of
# ActionDispatch::HostAuthorization, so you would get the challenge and then a
# blocked-host page once you authenticated.
#
#   curl -i -H "Host: www-idle.localhost" http://localhost:3000/robots.txt
#   curl -i -u idle:some-local-password -H "Host: www-idle.localhost" http://localhost:3000/robots.txt
#   curl -i http://localhost:3000/robots.txt
#
# A 401, then a 200, then one that was never challenged. Or open
# http://www-idle.localhost:3000/ for the login prompt a visitor would get.
#
# robots.txt is the probe worth using because ActionDispatch::Static serves it
# straight out of public/. If this ever stopped being first in the stack, that
# request is the one that would quietly go back to returning 200.
#
# Set the production credentials with `bin/rails credentials:edit --environment
# production`, under idle_basic_auth.
#
# Why the Host header
# -------------------
#
# Gating on the Host rather than on anything machine-specific means api-idle is
# untouched, the ALB health check isn't challenged (it sends the target's IP and
# port as the Host), and the protection follows the environment at cutover with
# no coordination needed.
#
# Registered in config/initializers/idle_basic_auth.rb with insert_before 0
# rather than use. There is no nginx in front of Rails here, so anything later
# in the stack would sit behind ActionDispatch::Static and serve public/
# unchallenged.
#
# What Cloudflare still serves
# ----------------------------
#
# www-idle is proxied through Cloudflare, so anything already in Cloudflare's
# cache never reaches Puma and is never challenged.
#
# Pages are safe. Cloudflare caches neither HTML nor a 401 by default: its
# default cacheable statuses are 200, 206, 301, 302, 303, 404 and 410.
#
# Static files are not safe. Cloudflare caches a fixed list of extensions by
# default (css, js, images, fonts, pdf and so on), which is what "caches by
# extension" means, and config/environments/production.rb serves everything in
# public/ with "Cache-Control: public, max-age=31536000". Cloudflare would
# normally decline to cache a response to a request carrying an Authorization
# header, but only while Origin Cache Control is on (the default outside
# Enterprise) and the response doesn't say public, s-maxage or must-revalidate.
# Ours says public, so that protection doesn't apply, and signing in to load a
# page can put the CSS, JS, fonts and images behind it into Cloudflare's cache.
# Accepted rather than fixed: asset paths carry a content digest, so a bot or a
# curious human has no way to know what to ask for if the file has changed, and
# if it hasn't, the path they could guess from the live environment returns the
# same bytes live already serves.
#
# Two ways to close it if we want to: a cache-bypass rule for www-idle in
# Cloudflare, or set "Cache-Control: no-store" here on what we let through,
# which Cloudflare honours under all circumstances.
class IdleBasicAuth
  extend T::Sig

  IDLE_HOST_PREFIX = T.let("www-idle", String)
  REALM = T.let("PlanningAlerts idle", String)

  sig { params(app: T.untyped).void }
  def initialize(app)
    @app = T.let(app, T.untyped)
  end

  sig { params(env: T::Hash[String, T.untyped]).returns(T.untyped) }
  def call(env)
    return @app.call(env) if !idle_host?(env) || authenticated?(env)

    [
      401,
      {
        "www-authenticate" => %(Basic realm="#{REALM}"),
        "content-type" => "text/plain"
      },
      ["Unauthorized\n"]
    ]
  end

  private

  # Deliberately reads HTTP_HOST rather than Rack::Request#host. The latter
  # prefers the client-supplied X-Forwarded-Host, which the ALB passes straight
  # through, so anyone could name a different host and skip the challenge.
  sig { params(env: T::Hash[String, T.untyped]).returns(T::Boolean) }
  def idle_host?(env)
    host = env["HTTP_HOST"].to_s.downcase.split(":").first.to_s
    host.start_with?(IDLE_HOST_PREFIX)
  end

  sig { params(env: T::Hash[String, T.untyped]).returns(T::Boolean) }
  def authenticated?(env)
    expected_username = configured(:username, "IDLE_BASIC_AUTH_USERNAME")
    expected_password = configured(:password, "IDLE_BASIC_AUTH_PASSWORD")
    # Fail closed. Leaving the idle environment open because a credential is missing
    # is the exact thing this middleware exists to prevent.
    return false if expected_username.blank? || expected_password.blank?

    given = given_credentials(env)
    return false if given.nil?

    given_username, given_password = given
    # Single & rather than &&, so a wrong username doesn't short-circuit and
    # leak the answer through how long the request took.
    ActiveSupport::SecurityUtils.secure_compare(given_username.to_s, expected_username) &
      ActiveSupport::SecurityUtils.secure_compare(given_password.to_s, expected_password)
  end

  # Credentials in production, environment in development, matching the
  # fallback config/initializers/sentry.rb already uses for the Sentry DSN.
  # There is no development.yml.enc key to share around.
  sig { params(key: Symbol, variable: String).returns(T.nilable(String)) }
  def configured(key, variable)
    Rails.application.credentials.dig(:idle_basic_auth, key) || ENV.fetch(variable, nil)
  end

  sig { params(env: T::Hash[String, T.untyped]).returns(T.nilable(T::Array[String])) }
  def given_credentials(env)
    scheme, encoded = env["HTTP_AUTHORIZATION"].to_s.split(" ", 2)
    return unless scheme&.casecmp("basic")&.zero?
    return if encoded.nil?

    decoded = Base64.decode64(encoded)
    return unless decoded.include?(":")

    decoded.split(":", 2)
  end
end
