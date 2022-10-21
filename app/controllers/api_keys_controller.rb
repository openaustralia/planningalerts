# typed: strict
# frozen_string_literal: true

class ApiKeysController < ApplicationController
  before_action :authenticate_user!

  sig { void }
  def create
    user = T.must(current_user)
    # For the time being limit users to only creating one API key
    if user.api_keys.empty?
      user.api_keys.create!
      redirect_to api_howto_url, notice: "API key created"
    else
      # This is a terrible way of showing an error but it's not likely to happen so I'm not going to worry about that
      redirect_to api_howto_url, notice: "You already have an API key"
    end
  end
end
