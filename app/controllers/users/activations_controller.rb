# typed: strict
# frozen_string_literal: true

module Users
  class ActivationsController < ApplicationController
    extend T::Sig

    layout "minimal"

    sig { void }
    def new
      @user = T.let(User.new, T.nilable(User))
    end

    sig { void }
    def create
      params_user = T.cast(params[:user], ActionController::Parameters)

      user = User.find_by(email: params_user[:email])
      # If the user doesn't exist then don't send an email but do everything else
      if user
        if user.requires_activation?
          user.send_activation_instructions
        else
          user.send_already_activated_instructions
        end
      end

      redirect_to new_user_session_path, notice: t(".success")
    end
  end
end
