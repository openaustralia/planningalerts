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
  def api_howto; end

  # rubocop:disable Naming/AccessorMethodName
  sig { void }
  def get_involved; end
  # rubocop:enable Naming/AccessorMethodName

  sig { void }
  def how_to_write_a_scraper; end

  sig { void }
  def how_to_lobby_your_local_council; end

  sig { void }
  def contact
    @reasons = T.let(
      [
        "-- Select closest relevant --",
        "I'm having trouble signing up",
        "I can't find a development application",
        "I've stopped receiving alerts",
        "I have a privacy concern",
        "I want to change or delete a comment I made",
        "The address or map location is wrong",
        "I have a question about how Planning Alerts works",
        "I'm trying to reach council",
        "Other, please specify below"
      ],
      T.nilable(T::Array[String])
    )
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
