# typed: strict
# frozen_string_literal: true

module Users
  class ActivationMailer < ApplicationMailer
    extend T::Sig

    sig { params(user: User, token: String).returns(T.any(Mail::Message, ActionMailer::MessageDelivery)) }
    def notify(user, token)
      @user = T.let(user, T.nilable(User))
      @token = T.let(token, T.nilable(String))

      headers(
        # If we're on the tailwind theme then disable css inlining because we're already
        # doing it with maizzle and the inlining on cuttlefish strips out media queries for
        # responsive designs and some more modern css features
        "X-Cuttlefish-Disable-Css-Inlining" => user.tailwind_theme.to_s
      )

      attachments.inline["illustration.png"] = Rails.root.join("app/assets/images/tailwind/illustration/confirmation.png").read if user.tailwind_theme

      mail(
        to: user.email,
        template_path: ("_tailwind/users/activation_mailer" if user.tailwind_theme)
      )
    end
  end
end
