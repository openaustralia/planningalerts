# frozen_string_literal: true

# You can preview the mails by browsing to http://localhost:3000/rails/mailers

require "factory_bot_rails"

module Users
  class ActivationMailerPreview < ActionMailer::Preview
    def notidy
      user = FactoryBot.build_stubbed(:user)
      ActivationMailer.notify(user, "faketoken")
    end
  end
end
