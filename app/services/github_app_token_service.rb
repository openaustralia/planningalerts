# typed: strict
# frozen_string_literal: true

# Authenticates to Github as the PlanningAlerts Bot Github App, so that broken scraper
# issues are created by an identity the organisation owns rather than by one person's
# personal access token.
#
# Github App authentication is two steps: sign a short lived JWT with the App's private
# key, then swap that for an installation access token that's good for an hour. We hang
# on to the installation token until it's nearly expired, because a single run of
# SyncGithubIssueForAuthorityService makes about a dozen requests and there's no sense
# minting a token for each one.
class GithubAppTokenService
  extend T::Sig

  class InstallationToken < T::Struct
    const :token, String
    const :expires_at, Time
  end

  # Get a new token when there's less than this left on the one we're holding
  EXPIRY_MARGIN = T.let(5.minutes, ActiveSupport::Duration)

  # How long the JWT is valid for. Github rejects anything over 10 minutes.
  JWT_VALIDITY = T.let(9.minutes, ActiveSupport::Duration)

  # Backdate the JWT slightly in case our clock is ahead of Github's
  JWT_CLOCK_SKEW = T.let(60.seconds, ActiveSupport::Duration)

  @cached_token = T.let(nil, T.nilable(InstallationToken))

  sig { returns(String) }
  def self.call
    cached_token = @cached_token
    return cached_token.token if cached_token && Time.zone.now < cached_token.expires_at - EXPIRY_MARGIN

    minted = new.call
    @cached_token = minted
    minted.token
  end

  # Mints a brand new installation access token. Callers should generally go through
  # .call so they get the cached one.
  sig { returns(InstallationToken) }
  def call
    response = Octokit::Client.new(bearer_token: jwt).create_app_installation_access_token(installation_id)
    InstallationToken.new(token: response.token, expires_at: response.expires_at)
  end

  private

  sig { returns(String) }
  def jwt
    now = Time.zone.now
    payload = {
      iat: (now - JWT_CLOCK_SKEW).to_i,
      exp: (now + JWT_VALIDITY).to_i,
      iss: app_id
    }
    JWT.encode(payload, OpenSSL::PKey::RSA.new(private_key), "RS256")
  end

  sig { returns(Integer) }
  def app_id
    Rails.application.credentials.dig(:github_app, :id)
  end

  sig { returns(Integer) }
  def installation_id
    Rails.application.credentials.dig(:github_app, :installation_id)
  end

  sig { returns(String) }
  def private_key
    Rails.application.credentials.dig(:github_app, :private_key)
  end
end
