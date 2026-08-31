# typed: strict
# frozen_string_literal: true

# The two secrets ALTCHA needs to sign a challenge and to recognise its own
# signature when the answer comes back.
#
# These are derived from secret_key_base rather than stored as their own
# credential. Deriving means there is nothing extra to add to two encrypted
# credential files, nothing to lose, and, most importantly, the secrets exist in
# the test environment. There is no config/credentials/test.yml.enc, so a
# credential read there returns nil, and code written around that ends up
# skipping the check entirely in test. The reCAPTCHA call in
# ContactMessagesController does exactly that. For a security control we do not
# want a version of the code where the control is silently absent.
#
# Both web servers already share secret_key_base, so a challenge issued by one
# verifies on the other. Rotating secret_key_base invalidates challenges that
# are in flight, which is harmless: they expire in minutes anyway, and rotating
# it already signs everyone out.
class AltchaSecretsService
  extend T::Sig

  class Secrets < T::Struct
    const :signature_secret, String
    const :key_signature_secret, String
  end

  # Bumping these salts rotates the secrets without touching secret_key_base.
  SIGNATURE_SALT = T.let("altcha/v1/hmac_signature", String)
  KEY_SIGNATURE_SALT = T.let("altcha/v1/hmac_key_signature", String)
  KEY_LENGTH = T.let(32, Integer)

  sig { returns(Secrets) }
  def self.call
    new.call
  end

  sig { returns(Secrets) }
  def call
    Secrets.new(
      signature_secret: derive(SIGNATURE_SALT),
      key_signature_secret: derive(KEY_SIGNATURE_SALT)
    )
  end

  private

  # Hex encoded so the secret is ASCII safe wherever the gem puts it.
  # key_generator is a CachingKeyGenerator, so the PBKDF2 cost is paid once per
  # process rather than once per request.
  sig { params(salt: String).returns(String) }
  def derive(salt)
    T.cast(Rails.application.key_generator.generate_key(salt, KEY_LENGTH), String).unpack1("H*")
  end
end
