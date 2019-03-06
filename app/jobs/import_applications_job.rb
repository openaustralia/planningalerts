# frozen_string_literal: true

class ImportApplicationsJob < ApplicationJob
  queue_as :default

  def perform(authority:, scrape_delay:)
    info_logger = AuthorityLogger.new(authority.id, logger)
    ImportApplicationsService.call(authority: authority, scrape_delay: scrape_delay, logger: info_logger, morph_api_key: ENV["MORPH_API_KEY"])
  end
end
