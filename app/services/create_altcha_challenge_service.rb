# typed: strict
# frozen_string_literal: true

# Builds one ALTCHA proof-of-work challenge for the widget to solve.
#
# COST and COUNTER_RANGE together decide how long the work takes in someone's
# browser. They are constants rather than inline numbers so that specs can stub
# them down and solve a challenge for real in milliseconds. Before turning
# altcha_enforce on, time these on a genuinely low-powered phone: too high and
# signing up feels broken, too low and it deters nobody.
class CreateAltchaChallengeService
  extend T::Sig

  ALGORITHM = T.let("PBKDF2/SHA-256", String)
  COST = T.let(5_000, Integer)
  COUNTER_RANGE = T.let((5_000..10_000), T::Range[Integer])
  # Long enough for someone to write a long contact message, short enough that
  # the altcha_solutions table stays small.
  EXPIRES_IN = T.let(10.minutes, ActiveSupport::Duration)

  sig { returns(T::Hash[T.untyped, T.untyped]) }
  def self.call
    new.call
  end

  sig { returns(T::Hash[T.untyped, T.untyped]) }
  def call
    secrets = AltchaSecretsService.call
    options = Altcha::V2::CreateChallengeOptions.new(
      algorithm: ALGORITHM,
      cost: COST,
      counter: SecureRandom.random_number(COUNTER_RANGE),
      expires_at: EXPIRES_IN.from_now,
      hmac_signature_secret: secrets.signature_secret,
      hmac_key_signature_secret: secrets.key_signature_secret
    )
    Altcha::V2.create_challenge(options).to_h
  end
end
