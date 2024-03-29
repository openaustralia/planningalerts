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
    # Lookup user based on email address. So, we don't KNOW for sure that this is the right person
    # and this can obviously be impersonated
    @possible_user = T.let(User.find_by(email: contact_message.email.downcase.strip), T.nilable(User))
    mail(
      to: "contact@planningalerts.org.au",
      from: "#{contact_message.name} <contact@planningalerts.org.au>",
      reply_to: "#{contact_message.name} <#{contact_message.email}>",
      subject: "Contact form: #{contact_message.reason}"
    )
  end
end
