# typed: true
# frozen_string_literal: true

# Controller for (mostly) static content
class StaticController < ApplicationController
  def about; end

  def faq; end

  # rubocop:disable Naming/AccessorMethodName
  def get_involved; end
  # rubocop:enable Naming/AccessorMethodName

  def how_to_write_a_scraper; end

  def how_to_lobby_your_local_council; end

  def error_404
    render status: :not_found, formats: [:html]
  end

  def error_500
    render status: :internal_server_error, formats: [:html]
  end
end
