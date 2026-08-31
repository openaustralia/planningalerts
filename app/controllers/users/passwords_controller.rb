# typed: strict
# frozen_string_literal: true

module Users
  # Subclasses Devise only so that the "forgot your password" form can carry an
  # ALTCHA check. Everything else is Devise's own behaviour.
  class PasswordsController < Devise::PasswordsController
    extend T::Sig

    # For sorbet
    include Devise::Controllers::Helpers

    # create is Devise's, which is the whole point of subclassing: we only want
    # to put a check in front of it.
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :check_altcha, only: :create
    # rubocop:enable Rails/LexicallyScopedActionFilter

    protected

    sig { void }
    def check_altcha
      return if altcha_ok?(form: :password_reset)

      self.resource = resource_class.new(email: params.dig(:user, :email))
      resource.errors.add(:base, t("altcha.failed"))
      render :new, status: :unprocessable_entity
    end
  end
end
