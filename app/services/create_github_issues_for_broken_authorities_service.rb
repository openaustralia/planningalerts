# typed: strict
# frozen_string_literal: true

class CreateGithubIssuesForBrokenAuthoritiesService < ApplicationService
  extend T::Sig

  sig { params(logger: Logger).void }
  def self.call(logger:)
    new.call(logger: logger)
  end

  sig { params(logger: Logger).void }
  def call(logger:)
    Authority.active.find_each do |authority|
      SyncGithubIssueForAuthorityService.call(logger: logger, authority: authority)
    end
  end
end
