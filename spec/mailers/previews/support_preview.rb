# frozen_string_literal: true

# You can preview the mails by browsing to http://localhost:3000/rails/mailers

require "factory_bot_rails"

class SupportPreview < ActionMailer::Preview
  def abuse_report
    report = FactoryBot.build_stubbed(:report)
    SupportMailer.report(report)
  end

  def contact_message_logged_in_user
    user = FactoryBot.build_stubbed(:user, name: "Fred", email: "fred@foo.bar")
    contact_message = FactoryBot.build_stubbed(:contact_message, name: user.name, email: user.email, details: "Please do some stuff.\n\nAnd here is a second paragraph.", user:)
    SupportMailer.contact_message(contact_message)
  end

  def contact_message_not_logged_in_user
    contact_message = FactoryBot.build_stubbed(:contact_message, name: "Fred", email: "fred@foo.bar", details: "Please do some stuff.\n\nAnd here is a second paragraph.")
    SupportMailer.contact_message(contact_message)
  end

  def reply_to_no_reply
    mail = Mail.new do
      from "fred@foo.bar"
      to "no-reply@planningalerts.org.au"
      body "I don't know how to do this"
    end
    mail.subject = "Please help me solve this problem"
    ReplyToNoReplyMailer.reply(mail)
  end
end
