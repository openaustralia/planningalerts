# typed: strict
# frozen_string_literal: true

class ApiKeysController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  layout "profile"

  sig { void }
  def index
    @api_keys = T.let(policy_scope(T.must(current_user).api_keys), T.untyped)
  end

  sig { void }
  def create
    authorize ApiKey
    user = T.must(current_user)

    # For the time being limit users to only creating one API key
    if user.api_keys.empty?
      # Create a trial key which automatically expires and has a low daily limit
      # TODO: Extract this
      user.api_keys.create!(daily_limit: ApiKey.default_daily_limit_trial, expires_at: ApiKey.default_trial_duration_days.days.from_now)
      redirect_to api_keys_url, notice: t(".success")
    else
      # This is a terrible way of showing an error but it's not likely to happen so I'm not going to worry about that
      redirect_to api_keys_url, notice: t(".already_have_key")
    end
  end

  sig { void }
  def confirm
    authorize ApiKey
  end
end
