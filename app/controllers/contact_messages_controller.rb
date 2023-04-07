# typed: strict
# frozen_string_literal: true

class ContactMessagesController < ApplicationController
  extend T::Sig
  include Recaptcha::Adapters::ControllerMethods

  sig { void }
  def create
    params_contact_message = T.cast(params[:contact_message], ActionController::Parameters)

    @contact_message = T.let(ContactMessage.new(
                               user: current_user,
                               name: current_user&.name || params_contact_message[:name],
                               email: current_user&.email || params_contact_message[:email],
                               reason: params_contact_message[:reason],
                               details: params_contact_message[:details],
                               attachments: params_contact_message[:attachments]
                             ), T.nilable(ContactMessage))
    if (current_user || verify_recaptcha(model: @contact_message)) && T.must(@contact_message).save
      SupportMailer.contact_message(T.must(@contact_message)).deliver_later
      redirect_to thank_you_contact_messages_url
    else
      render "documentation/contact"
    end
  end

  sig { void }
  def thank_you; end
end
