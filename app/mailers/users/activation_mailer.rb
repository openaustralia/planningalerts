# typed: strict
# frozen_string_literal: true

module Users
  class ActivationMailer < ApplicationMailer
    extend T::Sig

    sig { params(user: User, token: String).returns(T.any(Mail::Message, ActionMailer::MessageDelivery)) }
    def notify(user, token)
      @user = T.let(user, T.nilable(User))
      @token = T.let(token, T.nilable(String))

      mail(to: user.email)
    end
  end
end
