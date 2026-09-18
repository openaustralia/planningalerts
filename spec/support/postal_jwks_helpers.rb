# frozen_string_literal: true

# Builds the JWK Set that Postal publishes at /.well-known/jwks.json and stubs the fetch of it.
# The modulus and exponent are base64url encoded here the way Postal encodes them (RFC 7518
# section 6.3.1) rather than round tripped through the jwt gem, so that specs exercise our own
# parsing rather than the gem agreeing with itself.
module PostalJwksHelpers
  def jwks_json(*keys)
    { "keys" => keys.map { |key| jwk(key) } }.to_json
  end

  # Pass use: nil for a key with no "use" member at all, which RFC 7517 allows
  def jwk(key, use: "sig", kid: "postal")
    {
      "kty" => "RSA",
      "n" => Base64.urlsafe_encode64(key.n.to_s(2), padding: false),
      "e" => Base64.urlsafe_encode64(key.e.to_s(2), padding: false),
      "kid" => kid,
      "use" => use,
      "alg" => "RS256"
    }.compact
  end

  def stub_jwks(body:, code: 200)
    allow(HTTParty).to receive(:get)
      .with(Rails.configuration.x.postal_jwks_url, timeout: 2)
      .and_return(instance_double(HTTParty::Response, code:, body:))
  end
end
