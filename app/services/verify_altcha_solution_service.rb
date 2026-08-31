# typed: strict
# frozen_string_literal: true

# Checks one ALTCHA payload: that it decodes, that we issued the challenge, that
# the answer is right, that it has not expired, and that we have not already
# accepted it.
class VerifyAltchaSolutionService
  extend T::Sig

  class Failure < T::Enum
    enums do
      # No altcha field in the params at all. In monitor mode this is the
      # common case, and mostly means JavaScript did not run.
      Missing = new("missing")
      Malformed = new("malformed")
      Expired = new("expired")
      # We did not issue this challenge, or it has been edited since.
      InvalidSignature = new("invalid_signature")
      InvalidSolution = new("invalid_solution")
      # A correct answer we have accepted before.
      Replayed = new("replayed")
    end
  end

  class Result < T::Struct
    const :verified, T::Boolean
    const :failure, T.nilable(Failure)
  end

  sig { params(payload: T.nilable(String)).returns(Result) }
  def self.call(payload:)
    new(payload:).call
  end

  sig { params(payload: T.nilable(String)).void }
  def initialize(payload:)
    @payload = payload
  end

  sig { returns(Result) }
  def call
    payload = @payload
    return failed(Failure::Missing) if payload.blank?

    parsed = parse(payload)
    return failed(Failure::Malformed) if parsed.nil?

    secrets = AltchaSecretsService.call
    result = Altcha::V2.verify_solution(
      parsed.challenge,
      parsed.solution,
      hmac_signature_secret: secrets.signature_secret,
      hmac_key_signature_secret: secrets.key_signature_secret
    )

    return failed(Failure::Expired) if result.expired
    return failed(Failure::InvalidSignature) if result.invalid_signature
    return failed(Failure::InvalidSolution) unless result.verified

    # Only record an answer we have just decided is genuine. Doing this last
    # keeps the table free of a scripted attacker's rejected guesses.
    return failed(Failure::Replayed) unless record(parsed.challenge)

    Result.new(verified: true, failure: nil)
  end

  private

  sig { params(payload: String).returns(T.untyped) }
  def parse(payload)
    Altcha::V2::Payload.from_json(Base64.strict_decode64(payload))
  rescue ArgumentError, JSON::ParserError, NoMethodError, TypeError
    nil
  end

  sig { params(challenge: T.untyped).returns(T::Boolean) }
  def record(challenge)
    signature = challenge.signature
    return false if signature.blank?

    AltchaSolution.record!(
      signature:,
      expires_at: expires_at_for(challenge)
    )
  end

  # The gem exposes the expiry as unix seconds on the challenge parameters, not
  # on the challenge itself. Fall back to the challenge lifetime if it is
  # missing, so a row always has a time at which the sweeper may remove it.
  sig { params(challenge: T.untyped).returns(ActiveSupport::TimeWithZone) }
  def expires_at_for(challenge)
    expires_at = challenge.parameters&.expires_at
    return CreateAltchaChallengeService::EXPIRES_IN.from_now if expires_at.blank?

    Time.zone.at(expires_at)
  end

  sig { params(failure: Failure).returns(Result) }
  def failed(failure)
    Result.new(verified: false, failure:)
  end
end
