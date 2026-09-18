# frozen_string_literal: true

# Solves an ALTCHA challenge in Ruby, the way the widget would in a browser.
#
# This is what lets the whole feature be tested without driving a browser. Stub
# the cost down first, or the proof of work takes as long here as it would on
# somebody's phone:
#
#   stub_const("CreateAltchaChallengeService::COST", 100)
module AltchaHelpers
  # Returns the base64 payload the widget would put in the hidden altcha field.
  # Takes the hash the challenge endpoint serves, so a spec can go through the
  # same route a browser would.
  def solve_altcha_challenge(challenge = CreateAltchaChallengeService.call)
    parsed = Altcha::V2::Challenge.from_h(challenge.deep_stringify_keys)
    solution = Altcha::V2.solve_challenge(parsed)
    raise "Could not solve the ALTCHA challenge" if solution.nil?

    altcha_payload(challenge: parsed, solution:)
  end

  def altcha_payload(challenge:, solution:)
    Base64.strict_encode64(Altcha::V2::Payload.new(challenge:, solution:).to_json)
  end

  # The payload the widget submits when its own test attribute is set. It looks
  # like a payload but carries no challenge, so the server can never verify it.
  def mocked_altcha_payload
    Base64.strict_encode64({ challenge: nil, solution: nil, test: true }.to_json)
  end
end
