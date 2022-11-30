# typed: strict
# frozen_string_literal: true

module Users
  class ActivationsController < ApplicationController
    extend T::Sig

    layout "minimal"

    sig { void }
    def new
      user = User.new(email: params[:email])
      @user = T.let(user, T.nilable(User))
    end

    sig { void }
    def edit
      @user = User.new(reset_password_token: params[:token])
      @minimum_password_length = T.let(User.password_length.min, T.nilable(Integer))
    end

    sig { void }
    def create
      params_user = T.cast(params[:user], ActionController::Parameters)

      user = User.find_by(email: params_user[:email])
      # If the user doesn't exist then don't send an email but do everything else
      user&.send_activation_instructions

      redirect_to new_user_session_path, notice: t(".success")
    end

    sig { void }
    def update
      params_user = T.cast(params[:user], ActionController::Parameters)

      @user = User.reset_password_by_token(params_user)
      if @user.errors.empty?
        # TODO: Do this better
        @user.update!(name: params_user[:name])
        sign_in(@user)
        redirect_to after_sign_in_path_for(@user), notice: t(".success")
      else
        @minimum_password_length = T.let(User.password_length.min, T.nilable(Integer))
        render "edit"
      end
    end
  end
end