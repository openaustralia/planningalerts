# typed: strict
# frozen_string_literal: true

# Issues one ALTCHA proof-of-work challenge for the widget to solve.
#
# Deliberately not behind a feature flag. Issuing a challenge is cheap and
# harmless, and gating it would mean a form rendered a moment before a flag was
# switched off could no longer be completed.
class AltchaChallengesController < ApplicationController
  extend T::Sig

  # A challenge must be used once and by one person. Cloudflare sits in front of
  # production, and a cached challenge handed to everybody would make almost
  # every submission look like a replay, which is a miserable thing to debug.
  # This header is necessary but might not be sufficient: check there is no
  # Cloudflare cache rule overriding it for this path.
  before_action :do_not_cache

  # Nothing here should disturb where somebody gets sent after signing in.
  skip_before_action :store_user_location!

  sig { void }
  def show
    render json: CreateAltchaChallengeService.call
  end

  private

  sig { void }
  def do_not_cache
    response.headers["Cache-Control"] = "no-store"
  end
end
