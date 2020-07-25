# typed: strict
# frozen_string_literal: true

class CreateGithubIssuesForBrokenAuthoritiesService < ApplicationService
  extend T::Sig

  include GeneratedUrlHelpers
  include AuthoritiesHelper

  # The repository in which we want the issues created
  REPO = T.let(
    Rails.env.production? ? "planningalerts-scrapers/issues" : "planningalerts-scrapers/test-issues",
    String
  )

  sig { params(logger: Logger).void }
  def self.call(logger:)
    new.call(logger: logger)
  end

  sig { params(logger: Logger).void }
  def call(logger:)
    client = Octokit::Client.new(access_token: ENV["GITHUB_PERSONAL_ACCESS_TOKEN"])

    Authority.active.find_each do |authority|
      issue = authority.github_issue
      latest_date = authority.latest_date_scraped
      # We don't want to create issues on newly created authorities that have
      # not yet scraped anything
      if authority.broken? && latest_date && (issue.nil? || issue.closed?(client))
        logger.info "Creating GitHub issue for broken authority #{authority.full_name}"
        issue = client.create_issue(REPO, title(authority, latest_date), body(authority))
        authority.create_github_issue!(
          github_repo: REPO,
          github_number: issue.number
        )
      end
    end
  end

  sig { params(authority: Authority, latest_date: Time).returns(String) }
  def title(authority, latest_date)
    "#{authority.full_name}: No data received since #{latest_date.strftime('%e %b %Y')}"
  end

  sig { params(authority: Authority).returns(String) }
  def body(authority)
    "This issue has been **automatically** created by PlanningAlerts for " \
      "[#{authority.full_name}](#{authority_url(authority.short_name_encoded, host: ENV['HOST'])})\n\n" \
      "It uses the scraper [#{authority.morph_name}](#{morph_url(authority)})\n\n" \
      "Only close this issue once the authority is working again on PlanningAlerts. " \
      "Otherwise a new issue will just automatically created. Also, if there is " \
      "a duplicate issue close the other one in favour of this one."
  end
end
