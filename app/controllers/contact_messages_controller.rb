# typed: strict
# frozen_string_literal: true

class ContactMessagesController < ApplicationController
  extend T::Sig

  sig { void }
  def create
    params_contact_message = T.cast(params[:contact_message], ActionController::Parameters)

    @contact_message = T.let(ContactMessage.new(
                               user: current_user,
                               name: current_user&.name || params_contact_message[:name],
                               email: current_user&.email || params_contact_message[:email],
                               reason: params_contact_message[:reason],
                               details: params_contact_message[:details]
                             ), T.nilable(ContactMessage))
    if T.must(@contact_message).save
      # TODO: Redirect to a dedicated thank you page instead
      redirect_back(
        fallback_location: documentation_contact_path,
        alert: "Thank you for getting in touch. We will get back to you as soon as we can."
      )
    else
      render "documentation/contact"
    end
  end
end
