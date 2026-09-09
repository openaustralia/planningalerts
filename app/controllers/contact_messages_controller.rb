# typed: strict
# frozen_string_literal: true

class ContactMessagesController < ApplicationController
  extend T::Sig
  include Recaptcha::Adapters::ControllerMethods

  sig { void }
  def create
    contact_message = ContactMessage.new(contact_message_params)
    user = current_user
    if user
      contact_message.user = user
      contact_message.name = user.name
      contact_message.email = user.email
    end
    if human?(contact_message) && contact_message.save
      SupportMailer.contact_message(contact_message).deliver_later
      redirect_to thank_you_contact_messages_url
    else
      @contact_message = T.let(contact_message, T.nilable(ContactMessage))
      render "documentation/contact"
    end
  end

  sig { void }
  def thank_you; end

  private

  # This is the one form that already had an anti-spam check, so ALTCHA and
  # reCAPTCHA are alternatives here rather than both at once. Put a percentage
  # gate on the altcha flag and the two run side by side, on a sticky split, so
  # they can be compared. Whichever is shown is the one that is checked, so the
  # form is never left unprotected.
  #
  # That is also why the contact form has no monitor mode, unlike the other
  # protected forms: gathering monitor data would mean showing two captchas at
  # once, which is a poor experience for no real gain. Use the monitor numbers
  # from the other forms to decide, and switch this one last.
  sig { params(contact_message: ContactMessage).returns(T::Boolean) }
  def human?(contact_message)
    return true if current_user

    if altcha_enforced?
      return true if altcha_ok?(form: :contact_form)

      contact_message.errors.add(:base, t("altcha.failed"))
      return false
    end

    Rails.application.credentials[:recaptcha].nil? || verify_recaptcha(model: contact_message)
  end

  sig { returns(ActionController::Parameters) }
  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :reason, :details, { attachments: [] })
  end
end
