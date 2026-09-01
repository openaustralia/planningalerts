# typed: strict
# frozen_string_literal: true

# One row per ALTCHA challenge whose answer we have accepted.
#
# The altcha gem verifies that an answer is correct and unexpired, but it has no
# concept of an answer having been used before. Without this table a single
# solved challenge could be replayed until it expired, which would let one round
# of proof of work pay for a burst of submissions. Replay protection is entirely
# ours.
class AltchaSolution < ApplicationRecord
  extend T::Sig

  # Records that we have accepted this challenge, and returns false if we had
  # already accepted it. The unique index is what actually decides, so two
  # concurrent requests carrying the same answer cannot both win.
  sig { params(signature: String, expires_at: ActiveSupport::TimeWithZone).returns(T::Boolean) }
  def self.record!(signature:, expires_at:)
    # requires_new wraps this in a savepoint. Specs run inside a transaction
    # (use_transactional_fixtures), and an unhandled unique violation would
    # abort that transaction, making every later query in the example fail.
    # A savepoint keeps the failure local to this insert.
    transaction(requires_new: true) do
      create!(signature:, expires_at:)
    end
    true
  rescue ActiveRecord::RecordNotUnique
    false
  end
end
