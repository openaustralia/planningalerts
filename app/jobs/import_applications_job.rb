# typed: strict
# frozen_string_literal: true

# TODO: use sidekiq-unique-jobs to ensure that we can't have more than one ImportApplicationsJob running at a time
class ImportApplicationsJob
  extend T::Sig
  include Sidekiq::Job

  # Default number of days to look back (in date scraped) for new applications
  # This gives us a little latitude of a few days for this job to fail for one
  # reason or another
  SCRAPE_DELAY = 5

  sig { params(authority_id: Integer).void }
  def perform(authority_id)
    authority = Authority.find(authority_id)
    info_logger = AuthorityLogger.new(authority_id, logger)
    ImportApplicationsService.call(
      authority:,
      logger: info_logger,
      scrape_delay: SCRAPE_DELAY,
      morph_api_key: Rails.application.credentials[:morph_api_key]
    )
  end
end
