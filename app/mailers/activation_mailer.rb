# typed: strict
# frozen_string_literal: true

class ActivationMailer < ApplicationMailer
  extend T::Sig

  include Devise::Mailers::Helpers

  sig { params(user: User, token: String).returns(T.any(Mail::Message, ActionMailer::MessageDelivery)) }
  def notify(user, token)
    @token = T.let(token, T.nilable(String))
    @user = T.let(user, T.nilable(User))

    mail(
      # We want the same subject as the regular reset password email so the user can find the email
      subject: t("devise.mailer.reset_password_instructions.subject"),
      to: user.email,
      from: mailer_sender(devise_mapping),
      reply_to: mailer_reply_to(devise_mapping)
    )
  end
end
