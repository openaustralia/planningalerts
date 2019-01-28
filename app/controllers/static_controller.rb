# frozen_string_literal: true

# Controller for (mostly) static content
class StaticController < ApplicationController
  # Reinstate caching of faq page when all authorities have commenting feature
  # caches_page :about, :faq, :get_involved
  # Don't cache about page because we randomly rearrange the list of contributors on each request
  caches_page :get_involved, :how_to_write_a_scraper, :how_to_lobby_your_local_council

  def about; end

  def faq; end

  # rubocop:disable Naming/AccessorMethodName
  def get_involved; end
  # rubocop:enable Naming/AccessorMethodName

  def how_to_write_a_scraper; end

  def how_to_lobby_your_local_council; end

  def donate; end

  def error_404
    render status: :not_found, formats: [:html]
  end

  def error_500
    render status: :internal_server_error, formats: [:html]
  end
end
