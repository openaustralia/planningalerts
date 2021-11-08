# typed: strict
# frozen_string_literal: true

# Controller for (mostly) static content
class StaticController < ApplicationController
  extend T::Sig

  sig { void }
  def about; end

  sig { void }
  def faq; end

  # rubocop:disable Naming/AccessorMethodName
  sig { void }
  def get_involved; end
  # rubocop:enable Naming/AccessorMethodName

  sig { void }
  def how_to_write_a_scraper; end

  sig { void }
  def how_to_lobby_your_local_council; end

  sig { void }
  def error_404
    render status: :not_found, formats: [:html]
  end

  sig { void }
  def error_500
    render status: :internal_server_error, formats: [:html]
  end
end
