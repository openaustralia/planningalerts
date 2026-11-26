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

    context "when in development without github credentials" do
      let(:log) { StringIO.new }
      let(:logger) { Logger.new(log) }

      before do
        allow(Rails.env).to receive(:development?).and_return(true)
        allow(GithubAppTokenService).to receive(:configured?).and_return(false)
        create(:geocoded_application, authority:, date_scraped: 3.weeks.ago)
      end

      it "skips, and warns what it would have done" do
        described_class.call(logger:, authority:)

        expect(Octokit::Client).not_to have_received(:new)
        expect(log.string).to match(/WARN.*Skipping the GitHub issue sync for #{authority.full_name}.*create a GitHub issue for this broken authority/)
      end

      it "says it would have labelled an existing issue when the authority is working again" do
        authority.create_github_issue!(github_repo: "example/repo", github_number: 3)
        create(:geocoded_application, authority:, council_reference: "NEW/1", date_scraped: 1.day.ago)

        described_class.call(logger:, authority:)

        expect(log.string).to match(/label the existing GitHub issue "probably fixed"/)
      end
    end

    # Broken, but with a date to report, so an issue gets created and attached
    context "when an authority is broken" do
      let(:graphql_errors) { instance_double(GraphQL::Client::Errors, any?: false, messages: {}) }
      let(:graphql_data) { instance_double(GraphQL::Client::Response) }

      before do
        create(:geocoded_application, authority:, date_scraped: 3.weeks.ago)

        allow(octokit).to receive(:create_issue).and_return(
          Sawyer::Resource.new(Sawyer::Agent.new("https://api.github.com"), { number: 7, node_id: "I_node" })
        )
        allow(described_class::CLIENT).to receive(:query).and_return(graphql_data)
        allow(graphql_data).to receive(:errors).and_return(graphql_errors)
      end

      context "when github reports a graphql error" do
        let(:graphql_errors) do
          instance_double(GraphQL::Client::Errors, any?: true, messages: { "data" => ["Bad credentials"] })
        end

        it "raises rather than leaving the issue on the project with blank fields" do
          expect { described_class.call(logger:, authority:) }
            .to raise_error(/Github GraphQL request failed: Bad credentials/)
        end
      end

      context "when github finds the project" do
        let(:field) { Struct.new(:id) }
        let(:project) do
          Struct.new(:id, :authority_field, :latest_date_field, :scraper_field, :state_field,
                     :population_field, :website_field, :authority_admin_field)
                .new("P_project", *%w[F_authority F_date F_scraper F_state F_population F_website F_admin].map { |id| field.new(id) })
        end

        before do
          authority.update!(full_name: "Exampleton City Council", state: "NSW", population_2021: 12_345,
                            website_url: "https://www.exampleton.nsw.gov.au/", morph_name: "planningalerts-scrapers/exampleton")
          # graphql-client builds the data object from a dynamically generated class,
          # so there's no real constant to verify a double against. One object
          # answers all three queries: find the project, add the issue, set a field.
          data = Struct.new(:organization, :add_project_v2_item_by_id)
                       .new(Struct.new(:project_v2).new(project), Struct.new(:item).new(Struct.new(:id).new("I_item")))
          allow(graphql_data).to receive(:data).and_return(data)
        end

        it "creates an issue and fills in its project fields" do
          described_class.call(logger:, authority:)

          expect(authority.reload.github_issue.github_number).to eq 7
          {
            "F_authority" => { text: "Exampleton City Council" },
            "F_state" => { text: "NSW" },
            "F_population" => { number: 12_345 },
            "F_website" => { text: "https://www.exampleton.nsw.gov.au/" }
          }.each do |field_id, value|
            expect(described_class::CLIENT).to have_received(:query).with(
              described_class::UPDATE_FIELD_VALUE_MUTATION,
              variables: { input: { projectId: "P_project", itemId: "I_item", fieldId: field_id, value: } }
            )
          end
          expect(described_class::CLIENT).to have_received(:query).with(
            described_class::UPDATE_FIELD_VALUE_MUTATION,
            variables: { input: hash_including(fieldId: "F_date", value: { date: a_string_matching(/\A\d{4}-\d\d-\d\d/) }) }
          )
        end
      end

      context "when github returns no project, which is what a missing permission looks like" do
        before do
          # graphql-client builds the data object from a dynamically generated class,
          # so there's no real constant to verify a double against
          allow(graphql_data).to receive(:data).and_return(Struct.new(:organization).new(nil))
        end

        it "says which project it couldn't find" do
          expect { described_class.call(logger:, authority:) }
            .to raise_error(/Can't find project 4 in the planningalerts-scrapers organisation/)
        end
      end
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
