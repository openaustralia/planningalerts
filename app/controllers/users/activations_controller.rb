# typed: strict
# frozen_string_literal: true

module Users
  class ActivationsController < ApplicationController
    extend T::Sig

    sig { void }
    def new
      user = User.new(email: params[:email])
      @user = T.let(user, T.nilable(User))
    end

    sig { void }
    def edit
      # TODO: Handle case where @user is nil here - probably want to 404 or something like that?
      @user = User.new(reset_password_token: params[:token])
      @minimum_password_length = T.let(User.password_length.min, T.nilable(Integer))
    end

    sig { void }
    def create
      params_user = T.cast(params[:user], ActionController::Parameters)

      @user = User.find_by(email: params_user[:email])
      if @user && !@user.requires_activation?
        @user.errors.add(:email, :already_activated)
        render "new"
        return
      end

      # If the user doesn't exist then don't send an email but do everything else
      @user&.send_activation_instructions
    end

    sig { void }
    def update
      params_user = T.cast(params[:user], ActionController::Parameters)

      @user = User.reset_password_by_token(params_user)
      if @user.errors.empty?
        # TODO: Do this better
        @user.update!(name: params_user[:name], activated_at: Time.current)
        sign_in(@user)
        redirect_to after_sign_in_path_for(@user), notice: t(".success")
      else
        @minimum_password_length = T.let(User.password_length.min, T.nilable(Integer))
        render "edit"
      end
    end
  end
end
