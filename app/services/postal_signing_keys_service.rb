# typed: strict
# frozen_string_literal: true

# The public keys postal publishes for the key it signs webhooks with. Postal signs with one
# installation wide key and publishes the matching public key as a JWK Set at a well known URL,
# so we check signatures against whatever it publishes now rather than holding our own copy.
# A key rotation on the postal server then needs no change here.
# See https://docs.postalserver.io/developer/webhooks
class PostalSigningKeysService
  extend T::Sig

  # Postal gives up on a webhook after 5 seconds, and this runs inline in that request, so a
  # slower fetch than this is no use to us. HTTParty has no timeout at all by default.
  HTTP_TIMEOUT = 2

  # If we need to expire the cached copy for some reason then increment the version number below
  CACHE_KEY = "postal_signing_keys_service/v1"

  # Long enough that a burst of webhooks doesn't mean a fetch each, short enough that a signing
  # key rotation on the postal server heals inside the retries postal gives up after (2, 3, 6,
  # 10 and 15 minute backoffs, about 36 minutes in all). Deliberately no skip_nil: caching a
  # failed fetch too is what stops an outage turning into one outbound request per inbound
  # webhook on an endpoint anyone can post to, and postal's later retries land after it expires.
  CACHE_TTL = T.let(15.minutes, ActiveSupport::Duration)

  # When the cached copy expires, the first request bumps its expiry by this much and refreshes,
  # while requests arriving during the refresh keep getting the stale copy instead of a fetch
  # each. A refresh takes at most HTTP_TIMEOUT, so this only needs to cover that with slack.
  RACE_CONDITION_TTL = T.let(5.seconds, ActiveSupport::Duration)

  sig { returns(T.nilable(T::Array[OpenSSL::PKey::RSA])) }
  def self.call
    new.call
  end

  sig { returns(T.nilable(T::Array[OpenSSL::PKey::RSA])) }
  def call
    cached_pems&.map { |pem| OpenSSL::PKey::RSA.new(pem) }
  end

  private

  sig { returns(T.nilable(T::Array[String])) }
  def cached_pems
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL, race_condition_ttl: RACE_CONDITION_TTL) { pems }
  end

  # PEM strings rather than key objects, because these get cached and the production cache is
  # memcached, so whatever we store has to survive a round trip through Marshal.
  #
  # Returns nil if the keys can't be determined. Network level failures (timeouts, DNS, a dropped
  # or reset connection) are rescued here alongside a malformed body, so postal's web interface
  # being unreachable or broken degrades to "we can't check this signature" rather than an
  # unhandled 500 out of the controller. OpenSSL::OpenSSLError covers both a failed TLS handshake
  # and unusable key material. Programming errors are deliberately left unrescued.
  sig { returns(T.nilable(T::Array[String])) }
  def pems
    response = HTTParty.get(jwks_url, timeout: HTTP_TIMEOUT)
    return nil unless response.code == 200

    parsed = JSON.parse(response.body)
    return nil unless parsed.is_a?(Hash)

    jwks = parsed["keys"]
    return nil unless jwks.is_a?(Array)

    jwks.filter_map { |jwk| signing_key_pem(jwk) }.presence
  rescue Timeout::Error, SocketError, SystemCallError, EOFError, Net::ProtocolError, Net::HTTPBadResponse,
         Net::HTTPHeaderSyntaxError, JSON::ParserError, JWT::DecodeError, OpenSSL::OpenSSLError
    nil
  end

  # Postal publishes one RS256 signing key, but the format allows several and allows keys that
  # aren't for signatures at all, so pick out only RSA keys marked for signature use. "use" is
  # optional in RFC 7517, so a key without one is accepted, while an encryption key never is.
  # The kty check is load bearing rather than cosmetic: JWT::JWK::HMAC::KTYS includes String,
  # so an oct entry otherwise yields a JWK whose verify_key is a String.
  sig { params(jwk: T.untyped).returns(T.nilable(String)) }
  def signing_key_pem(jwk)
    return nil unless jwk.is_a?(Hash)
    return nil unless jwk["kty"] == "RSA"
    return nil unless jwk["use"].nil? || jwk["use"] == "sig"
    # A non-string modulus or exponent goes straight to Base64.urlsafe_decode64 inside the jwt
    # gem and dies with a NoMethodError, which isn't one of its own rescuable errors
    return nil unless jwk["n"].is_a?(String) && jwk["e"].is_a?(String)

    # verify_key builds the key lazily, so force it here, inside the rescue above
    T.cast(JWT::JWK.new(jwk).verify_key, OpenSSL::PKey::RSA).to_pem
  end

  sig { returns(String) }
  def jwks_url
    Rails.configuration.x.postal_jwks_url
  end
end
