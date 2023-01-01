# typed: strict
# frozen_string_literal: true

require "graphql/client"
require "graphql/client/http"

# For a broken authority create a Github issue. When the authority is working
# again tag the Github issue as "probably fixed"
class SyncGithubIssueForAuthorityService
  extend T::Sig

  # include GeneratedUrlHelpers
  # See https://sorbet.org/docs/error-reference#4002
  T.unsafe(self).include Rails.application.routes.url_helpers
  include AuthoritiesHelper

  # First setup all the graphql stuff
  HTTP = T.let(GraphQL::Client::HTTP.new("https://api.github.com/graphql") do
    extend T::Sig
    sig { params(_context: T.untyped).returns(T::Hash[Symbol, String]) }
    def headers(_context)
      { Authorization: "bearer #{ENV.fetch('GITHUB_PERSONAL_ACCESS_TOKEN', nil)}" }
    end
  end, GraphQL::Client::HTTP)

  # TODO: Put the schema file in a sensible place
  # We're using a hardcoded version of the downloaded github graphQL schema during testing
  # so that we're not having to download anything from github and we're not having to set a
  # personal access token up for test either
  SCHEMA_PATH = T.let(Rails.env.test? ? "spec/fixtures/github_graphql_schema.json" : "schema.json", String)
  SCHEMA = T.let(if File.exist?(SCHEMA_PATH)
                   GraphQL::Client.load_schema(SCHEMA_PATH)
                 else
                   schema = GraphQL::Client.load_schema(HTTP)
                   GraphQL::Client.dump_schema(HTTP, SCHEMA_PATH)
                   schema
                 end, T.untyped)

  CLIENT = T.let(GraphQL::Client.new(schema: SCHEMA, execute: HTTP), GraphQL::Client)

  # First find the project we want to attach the issue to
  SHOW_PROJECT_QUERY_TEXT = <<-GRAPHQL
    query($login: String!, $number: Int!) {
      organization(login: $login) {
        projectV2(number: $number) {
          id
          authorityField: field(name: "Authority") {
            ... on ProjectV2FieldCommon {
              id
            }
          }
          latestDateField: field(name: "No data received since") {
            ... on ProjectV2FieldCommon {
              id
            }
          }
          scraperField: field(name: "Scraper (Morph)") {
            ... on ProjectV2FieldCommon {
              id
            }
          }
          stateField: field(name: "State") {
            ... on ProjectV2FieldCommon {
              id
            }
          }
          populationField: field(name: "Population") {
            ... on ProjectV2FieldCommon {
              id
            }
          }
          websiteField: field(name: "Website") {
            ... on ProjectV2FieldCommon {
              id
            }
          }
          authorityAdminField: field(name: "Authority admin (PA)") {
            ... on ProjectV2FieldCommon {
              id
            }
          }
        }
      }
    }
  GRAPHQL

  ADD_ISSUE_TO_PROJECT_MUTATION_TEXT = <<-GRAPHQL
    mutation($input: AddProjectV2ItemByIdInput!) {
      addProjectV2ItemById(input: $input) {
        item {
          id
        }
      }
    }
  GRAPHQL

  UPDATE_FIELD_VALUE_MUTATION_TEXT = <<-GRAPHQL
    mutation($input: UpdateProjectV2ItemFieldValueInput!) {
      updateProjectV2ItemFieldValue(input: $input)
    }
  GRAPHQL

  SHOW_PROJECT_QUERY = T.let(CLIENT.parse(SHOW_PROJECT_QUERY_TEXT), GraphQL::Client::OperationDefinition)
  ADD_ISSUE_TO_PROJECT_MUTATION = T.let(CLIENT.parse(ADD_ISSUE_TO_PROJECT_MUTATION_TEXT), GraphQL::Client::OperationDefinition)
  UPDATE_FIELD_VALUE_MUTATION = T.let(CLIENT.parse(UPDATE_FIELD_VALUE_MUTATION_TEXT), GraphQL::Client::OperationDefinition)

  # Issues and project sit under this
  ORG = "planningalerts-scrapers"

  # The repository in which we want the issues created and the project that the issues are added to
  if Rails.env.production?
    REPO = "issues"
    PROJECT_NUMBER = 3
  else
    REPO = "test-issues"
    PROJECT_NUMBER = 4
  end

  PROBABLY_FIXED_LABEL_NAME = "probably fixed"

  sig { params(logger: Logger, authority: Authority).void }
  def self.call(logger:, authority:)
    new.call(logger:, authority:)
  end

  sig { params(logger: Logger, authority: Authority).void }
  def call(logger:, authority:)
    client = Octokit::Client.new(access_token: ENV.fetch("GITHUB_PERSONAL_ACCESS_TOKEN", nil))

    issue = authority.github_issue
    latest_date = authority.date_last_new_application_scraped
    # We don't want to create issues on newly created authorities that have
    # not yet scraped anything
    if authority.broken? && latest_date && (issue.nil? || issue.closed?(client))
      logger.info "Creating GitHub issue for broken authority #{authority.full_name}"
      issue = client.create_issue("#{ORG}/#{REPO}", title(authority), body)
      authority.create_github_issue!(
        github_repo: "#{ORG}/#{REPO}",
        github_number: issue.number
      )
      # We also want to attach the issue to a project with some custom fields which makes it
      # easier to order / prioritise the work of fixing the scrapers
      attach_issue_to_project(issue_id: issue.node_id, authority:, latest_date:)
    elsif !authority.broken? && issue && !issue.closed?(client)
      logger.info "Authority #{authority.full_name} is fixed but github issue is still open. So labelling."
      issue.add_label!(client, PROBABLY_FIXED_LABEL_NAME)
    end
  end

  sig { params(issue_id: String, authority: Authority, latest_date: Time).void }
  def attach_issue_to_project(issue_id:, authority:, latest_date:)
    result = CLIENT.query(SHOW_PROJECT_QUERY, variables: { login: ORG, number: PROJECT_NUMBER })
    project = result.data.organization.project_v2

    # Now add the issue to the project
    result = CLIENT.query(ADD_ISSUE_TO_PROJECT_MUTATION, variables: { input: { projectId: project.id, contentId: issue_id } })
    item = result.data.add_project_v2_item_by_id.item
    # TODO: Check for errors

    if project.authority_field.nil? || project.latest_date_field.nil? || project.scraper_field.nil? || project.state_field.nil? ||
       project.population_field.nil? || project.website_field.nil? || project.authority_admin_field.nil?
      raise "Can't find all the required custom fields for the project"
    end

    update_text_field(project:, item:, field: project.authority_field, value: authority.full_name)
    update_date_field(project:, item:, field: project.latest_date_field, value: latest_date)
    update_text_field(project:, item:, field: project.scraper_field, value: morph_url(authority))
    update_text_field(project:, item:, field: project.state_field, value: authority.state)
    update_number_field(project:, item:, field: project.population_field, value: authority.population_2017)
    update_text_field(project:, item:, field: project.website_field, value: authority.website_url)
    update_text_field(project:, item:, field: project.authority_admin_field, value: admin_authority_url(authority, host: ENV.fetch("HOST", nil)))
  end

  sig { params(project: T.untyped, item: T.untyped, field: T.untyped, value: T.nilable(String)).void }
  def update_text_field(project:, item:, field:, value:)
    update_field(project:, item:, field:, type: :text, value:)
  end

  sig { params(project: T.untyped, item: T.untyped, field: T.untyped, value: Time).void }
  def update_date_field(project:, item:, field:, value:)
    update_field(project:, item:, field:, type: :date, value: value.iso8601)
  end

  sig { params(project: T.untyped, item: T.untyped, field: T.untyped, value: T.nilable(Integer)).void }
  def update_number_field(project:, item:, field:, value:)
    update_field(project:, item:, field:, type: :number, value:)
  end

  sig { params(project: T.untyped, item: T.untyped, field: T.untyped, type: Symbol, value: T.nilable(T.any(String, Integer))).void }
  def update_field(project:, item:, field:, type:, value:)
    CLIENT.query(UPDATE_FIELD_VALUE_MUTATION, variables: { input: { projectId: project.id, itemId: item.id, fieldId: field.id, value: { type => value } } })
    # TODO: Check for errors
  end

  sig { params(authority: Authority).returns(String) }
  def title(authority)
    authority.full_name
  end

  sig { returns(String) }
  def body
    "This issue has been **automatically** created by PlanningAlerts. " \
      "Only close this issue once the authority is working again on PlanningAlerts."
  end
end
