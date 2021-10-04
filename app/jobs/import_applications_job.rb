# typed: strict
# frozen_string_literal: true

class ImportApplicationsJob < ApplicationJob
  extend T::Sig

  queue_as :default

  sig { params(authority: Authority).void }
  def perform(authority:)
    info_logger = AuthorityLogger.new(T.must(authority.id), logger)
    ImportApplicationsService.call(authority: authority, logger: info_logger)
  end
end
