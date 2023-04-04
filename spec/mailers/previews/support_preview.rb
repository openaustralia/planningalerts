# frozen_string_literal: true

# You can preview the mails by browsing to http://localhost:3000/rails/mailers

require "factory_bot_rails"

class SupportPreview < ActionMailer::Preview
  def abuse_report
    report = FactoryBot.build_stubbed(:report)
    SupportMailer.report(report)
  end

  def contact_message
    user = FactoryBot.build_stubbed(:user, name: "Fred", email: "fred@foo.bar")
    contact_message = FactoryBot.build_stubbed(:contact_message, name: user.name, email: user.email, details: "Please do some stuff.\n\nAnd here is a second paragraph.", user:)
    SupportMailer.contact_message(contact_message)
  end
end
