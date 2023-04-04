# typed: strict
# frozen_string_literal: true

class SupportMailer < ApplicationMailer
  extend T::Sig

  helper :comments

  sig { params(report: Report).returns(T.any(Mail::Message, ActionMailer::MessageDelivery)) }
  def report(report)
    @report = T.let(report, T.nilable(Report))
    mail(
      to: ENV.fetch("EMAIL_MODERATOR", nil),
      from: "#{report.name} <#{ENV.fetch('EMAIL_MODERATOR', nil)}>",
      reply_to: "#{report.name} <#{report.email}>"
    )
  end

  sig { params(contact_message: ContactMessage).returns(T.any(Mail::Message, ActionMailer::MessageDelivery)) }
  def contact_message(contact_message)
    @contact_message = T.let(contact_message, T.nilable(ContactMessage))
    mail(
      to: ENV.fetch("EMAIL_MODERATOR", nil),
      from: "#{contact_message.name} <#{ENV.fetch('EMAIL_MODERATOR', nil)}>",
      reply_to: "#{contact_message.name} <#{contact_message.email}>",
      subject: "Contact form: #{contact_message.reason}"
    )
  end
end
