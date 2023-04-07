# typed: strict
# frozen_string_literal: true

class ContactMessagesController < ApplicationController
  extend T::Sig
  include Recaptcha::Adapters::ControllerMethods

  sig { void }
  def create
    @contact_message = T.let(ContactMessage.new(contact_message_params), T.nilable(ContactMessage))
    user = current_user
    if user
      T.must(@contact_message).user = user
      T.must(@contact_message).name = user.name
      T.must(@contact_message).email = user.email
    end
    if (current_user || verify_recaptcha(model: @contact_message)) && T.must(@contact_message).save
      SupportMailer.contact_message(T.must(@contact_message)).deliver_later
      redirect_to thank_you_contact_messages_url
    else
      render "documentation/contact"
    end
  end

  sig { void }
  def thank_you; end

  private

  sig { returns(ActionController::Parameters) }
  def contact_message_params
    T.cast(params.require(:contact_message), ActionController::Parameters).permit(:name, :email, :reason, :details, { attachments: [] })
  end
end
