# typed: strict
# frozen_string_literal: true

class GithubIssue < ApplicationRecord
  extend T::Sig
  belongs_to :authority

  # Use the GitHub API to get the issue state
  sig { params(client: Octokit::Client).returns(String) }
  def state(client)
    github_issue(client).state
  end

  sig { params(client: Octokit::Client).returns(T::Boolean) }
  def closed?(client)
    state(client) == "closed"
  end

  private

  sig { params(client: Octokit::Client).returns(T.untyped) }
  def github_issue(client)
    @github_issue = T.let(@github_issue, T.nilable(Sawyer::Resource))
    @github_issue ||= client.issue(github_repo, github_number)
  end
end
