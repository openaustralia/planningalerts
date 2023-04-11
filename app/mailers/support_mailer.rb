# typed: strict
# frozen_string_literal: true

class SupportMailer < ApplicationMailer
  extend T::Sig

  helper :comments

  sig { params(report: Report).returns(T.any(Mail::Message, ActionMailer::MessageDelivery)) }
  def report(report)
    @report = T.let(report, T.nilable(Report))
    mail(
      to: "contact@planningalerts.org.au",
      from: "#{report.name} <contact@planningalerts.org.au>",
      reply_to: "#{report.name} <#{report.email}>"
    )
  end

  sig { params(contact_message: ContactMessage).returns(T.any(Mail::Message, ActionMailer::MessageDelivery)) }
  def contact_message(contact_message)
    @contact_message = T.let(contact_message, T.nilable(ContactMessage))
    mail(
      to: "contact@planningalerts.org.au",
      from: "#{contact_message.name} <contact@planningalerts.org.au>",
      reply_to: "#{contact_message.name} <#{contact_message.email}>",
      subject: "Contact form: #{contact_message.reason}"
    )
  end
end
