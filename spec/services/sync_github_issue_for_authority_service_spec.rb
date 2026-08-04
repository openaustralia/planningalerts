# frozen_string_literal: true

require "spec_helper"

describe SyncGithubIssueForAuthorityService do
  # Real objects rather than doubles, because the sigs on .call, GithubIssue#closed?
  # and GithubIssue#add_label! are all checked at runtime by sorbet
  let(:logger) { Logger.new(File::NULL) }
  let(:octokit) { Octokit::Client.new }

  before do
    # Memoise the real client before stubbing the constructor below
    real_client = octokit

    allow(GithubAppTokenService).to receive(:call).and_return("ghs_installationtoken")
    allow(Octokit::Client).to receive(:new).and_return(real_client)
  end

  describe "graphql authentication" do
    it "authenticates as the github app" do
      expect(described_class::HTTP.headers(nil)).to eq(Authorization: "bearer ghs_installationtoken")
    end

    it "gets a token per request, so that merely loading the class doesn't talk to github" do
      described_class::HTTP.headers(nil)
      described_class::HTTP.headers(nil)

      expect(GithubAppTokenService).to have_received(:call).twice
    end
  end

  describe ".call" do
    let(:authority) { create(:authority) }

    # An authority with no applications at all is broken but has no date to report,
    # so nothing is created. Just enough to check how the client is built.
    it "builds the octokit client with a github app token" do
      described_class.call(logger:, authority:)

      expect(Octokit::Client).to have_received(:new).with(access_token: "ghs_installationtoken")
    end

    context "when a broken authority starts working again and its issue is still open" do
      before do
        create(:geocoded_application, authority:)
        authority.create_github_issue!(github_repo: "planningalerts-scrapers/test-issues", github_number: 42)

        allow(octokit).to receive(:issue).and_return(
          Sawyer::Resource.new(Sawyer::Agent.new("https://api.github.com"), { state: "open" })
        )
        allow(octokit).to receive(:add_labels_to_an_issue)
      end

      it "labels the issue as probably fixed, authenticated as the github app" do
        described_class.call(logger:, authority:)

        expect(Octokit::Client).to have_received(:new).with(access_token: "ghs_installationtoken")
        expect(octokit).to have_received(:add_labels_to_an_issue)
          .with("planningalerts-scrapers/test-issues", 42, ["probably fixed"])
      end
    end
  end
end
