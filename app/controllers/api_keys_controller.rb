# typed: strict
# frozen_string_literal: true

class ApiKeysController < ApplicationController
  before_action :authenticate_user!

  layout "profile", only: %i[index confirm]
  # TODO: Add pundit here

  sig { void }
  def index
    # TODO: Shouldn't be able to access this unless feature flag is set
    @api_keys = T.let(T.must(current_user).api_keys, T.untyped)
  end

  sig { void }
  def create
    user = T.must(current_user)
    redirect_url = if Flipper.enabled?(:api_keys_in_profile, current_user)
                     api_keys_url
                   else
                     api_howto_url
                   end

    # For the time being limit users to only creating one API key
    if user.api_keys.empty?
      if Flipper.enabled?(:api_keys_in_profile, current_user)
        # Create a trial key which automatically expires and has a low daily limit
        # TODO: Extract this
        user.api_keys.create!(daily_limit: ApiKey.default_daily_limit_trial, expires_at: ApiKey.default_trial_duration_days.days.from_now)
      else
        user.api_keys.create!
      end
      redirect_to redirect_url, notice: t(".success")
    else
      # This is a terrible way of showing an error but it's not likely to happen so I'm not going to worry about that
      redirect_to redirect_url, notice: t(".already_have_key")
    end
  end

  sig { void }
  def confirm; end
end
