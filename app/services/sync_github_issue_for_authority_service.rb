# typed: strict
# frozen_string_literal: true

# For a broken authority create a Github issue. When the authority is working
# again tag the Github issue as "probably fixed"
class SyncGithubIssueForAuthorityService
  extend T::Sig

  # include GeneratedUrlHelpers
  # See https://sorbet.org/docs/error-reference#4002
  T.unsafe(self).include Rails.application.routes.url_helpers
  include AuthoritiesHelper

  # The repository in which we want the issues created
  REPO = T.let(
    Rails.env.production? ? "planningalerts-scrapers/issues" : "planningalerts-scrapers/test-issues",
    String
  )

  PROBABLY_FIXED_LABEL_NAME = "probably fixed"

  sig { params(logger: Logger, authority: Authority).void }
  def self.call(logger:, authority:)
    new.call(logger: logger, authority: authority)
  end

  sig { params(logger: Logger, authority: Authority).void }
  def call(logger:, authority:)
    client = Octokit::Client.new(access_token: ENV["GITHUB_PERSONAL_ACCESS_TOKEN"])

    issue = authority.github_issue
    latest_date = authority.date_last_new_application_scraped
    # We don't want to create issues on newly created authorities that have
    # not yet scraped anything
    if authority.broken? && latest_date && (issue.nil? || issue.closed?(client))
      logger.info "Creating GitHub issue for broken authority #{authority.full_name}"
      issue = client.create_issue(REPO, title(authority, latest_date), body(authority))
      authority.create_github_issue!(
        github_repo: REPO,
        github_number: issue.number
      )
    elsif !authority.broken? && issue && !issue.closed?(client)
      logger.info "Authority #{authority.full_name} is fixed but github issue is still open. So labelling."
      issue.add_label!(client, PROBABLY_FIXED_LABEL_NAME)
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
