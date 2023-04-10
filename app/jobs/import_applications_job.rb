# typed: strict
# frozen_string_literal: true

# TODO: use sidekiq-unique-jobs to ensure that we can't have more than one ImportApplicationsJob running at a time
class ImportApplicationsJob
  extend T::Sig
  include Sidekiq::Job

  sig { params(authority_id: Integer).void }
  def perform(authority_id)
    authority = Authority.find(authority_id)
    info_logger = AuthorityLogger.new(authority_id, logger)
    scrape_delay = T.must(ENV.fetch("SCRAPE_DELAY", nil)).to_i
    ImportApplicationsService.call(authority:, logger: info_logger, scrape_delay:)
  end
end
