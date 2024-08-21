# typed: strict
# frozen_string_literal: true

# Pages that are largely documentation belong here
class DocumentationController < ApplicationController
  extend T::Sig

  sig { void }
  def about; end

  sig { void }
  def faq; end

  sig { void }
  def api_howto
    # If feature flag is enabled show a new landing page instead
    # with a link to an extracted "API Developer Documentation" page
    return unless Flipper.enabled?(:api_keys_in_profile, current_user)

    render "api_landing"
  end

  sig { void }
  def api_developer
    raise ActiveRecord::RecordNotFound unless Flipper.enabled?(:api_keys_in_profile, current_user)
  end

  # rubocop:disable Naming/AccessorMethodName
  sig { void }
  def get_involved; end
  # rubocop:enable Naming/AccessorMethodName

  sig { void }
  def how_to_write_a_scraper; end

  sig { void }
  def how_to_lobby_your_local_council; end

  # TODO: Move this action to ContactMessagesController#new
  sig { void }
  def contact
    # Allow the auto reply to no-reply to prepopulate the email field to make things a tiny bit easier
    # Also allow the reason to be chosen automatically if asking about the API
    @contact_message = T.let(ContactMessage.new(name: params[:name], email: params[:email], reason: params[:reason]), T.nilable(ContactMessage))
  end

  sig { void }
  def error_404
    render status: :not_found, formats: [:html]
  end

  sig { void }
  def error_500
    render status: :internal_server_error, formats: [:html]
  end
end
