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

    # Devise yields the resource before it decides whether to sign the person in,
    # so confirming here is what lets an unconfirmed person in after a reset.
    sig { void }
    def update
      super { |user| confirm_after_reset(user) }
    end

    protected

    # The reset link only goes to the account's email address, so completing it proves
    # ownership just as the activation form does. A pending email change is left alone:
    # the reset may have gone to the old address, so it says nothing about the new one.
    sig { params(user: User).void }
    def confirm_after_reset(user)
      return unless user.errors.empty? && !user.confirmed? && !user.pending_reconfirmation?

      user.confirm
    end

    sig { void }
    def check_altcha
      return if altcha_ok?(form: :password_reset)

      self.resource = resource_class.new(email: params.dig(:user, :email))
      resource.errors.add(:base, t("altcha.failed"))
      render :new, status: :unprocessable_content
    end
  end
end
