# typed: strict
# frozen_string_literal: true

# TODO: Move over to using a sidekiq job directly (rather than active job)
# TODO: use sidekiq-unique-jobs to ensure that we can't have more than one ImportApplicationsJob running at a time
class ImportApplicationsJob < ApplicationJob
  extend T::Sig

  queue_as :default

  sig { params(authority: Authority).void }
  def perform(authority)
    info_logger = AuthorityLogger.new(T.must(authority.id), logger)
    ImportApplicationsService.call(authority:, logger: info_logger)
  end
end
