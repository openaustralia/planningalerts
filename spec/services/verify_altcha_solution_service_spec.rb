# frozen_string_literal: true

require "spec_helper"

describe VerifyAltchaSolutionService do
  # A real challenge is genuinely solved in these examples, so keep the work
  # small enough that the suite stays fast.
  before { stub_const("CreateAltchaChallengeService::COST", 100) }

  let(:challenge) { CreateAltchaChallengeService.call }
  let(:payload) { solve_altcha_challenge(challenge) }

  # Decodes a payload, lets the block tamper with it, and re-encodes it.
  def tamper(payload)
    parsed = Altcha::V2::Payload.from_json(Base64.strict_decode64(payload))
    yield parsed
    altcha_payload(challenge: parsed.challenge, solution: parsed.solution)
  end

  describe ".call" do
    it "accepts a correctly solved challenge" do
      result = described_class.call(payload:)

      expect(result.verified).to be true
      expect(result.failure).to be_nil
    end

    it "reports a missing payload, which is what we see when javascript didn't run" do
      result = described_class.call(payload: nil)

      expect(result.verified).to be false
      expect(result.failure).to eq described_class::Failure::Missing
    end

    it "reports a blank payload as missing rather than malformed" do
      expect(described_class.call(payload: "").failure).to eq described_class::Failure::Missing
    end

    it "reports something that isn't base64 as malformed" do
      expect(described_class.call(payload: "not base64 at all!").failure)
        .to eq described_class::Failure::Malformed
    end

    it "reports base64 that isn't a payload as malformed" do
      rubbish = Base64.strict_encode64({ hello: "world" }.to_json)

      expect(described_class.call(payload: rubbish).failure).to eq described_class::Failure::Malformed
    end

    # This is exactly what the widget submits when its own test attribute is
    # set, so it is also what a bot could copy from our specs.
    it "reports the widget's own mocked payload as malformed" do
      expect(described_class.call(payload: mocked_altcha_payload).failure)
        .to eq described_class::Failure::Malformed
    end

    it "reports an expired challenge" do
      expired = Timecop.freeze(11.minutes.ago) { solve_altcha_challenge(CreateAltchaChallengeService.call) }

      expect(described_class.call(payload: expired).failure).to eq described_class::Failure::Expired
    end

    it "reports a challenge we didn't issue" do
      forged = tamper(payload) { |p| p.challenge.signature = "0" * 64 }

      expect(described_class.call(payload: forged).failure)
        .to eq described_class::Failure::InvalidSignature
    end

    # The derived key is the proof of work, not the counter: the counter is only
    # how the widget says it got there.
    it "reports an answer that isn't the right one" do
      wrong = tamper(payload) { |p| p.solution.derived_key = "00" * 32 }

      expect(described_class.call(payload: wrong).failure)
        .to eq described_class::Failure::InvalidSolution
    end

    it "reports an answer with no proof of work at all" do
      empty = tamper(payload) { |p| p.solution.derived_key = nil }

      expect(described_class.call(payload: empty).failure)
        .to eq described_class::Failure::InvalidSolution
    end

    it "accepts a correct answer once and rejects it after that" do
      expect(described_class.call(payload:).verified).to be true

      second = described_class.call(payload:)
      expect(second.verified).to be false
      expect(second.failure).to eq described_class::Failure::Replayed
    end

    it "remembers an accepted answer until its challenge would have expired" do
      described_class.call(payload:)
      solution = AltchaSolution.last

      expect(solution.signature).to eq challenge["signature"]
      expect(solution.expires_at).to be_within(1.second)
        .of(Time.zone.at(challenge["parameters"]["expiresAt"]))
    end

    it "doesn't record an answer it rejected, so guesses can't fill the table" do
      wrong = tamper(payload) { |p| p.solution.derived_key = "00" * 32 }

      expect { described_class.call(payload: wrong) }.not_to change(AltchaSolution, :count)
    end
  end
end
