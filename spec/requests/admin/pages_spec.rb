# frozen_string_literal: true

require "spec_helper"

# Smoke tests for every admin page. These use the administrate layout, so
# they skip have_site_layout.
describe "Admin pages" do
  # TODO: #2166 Include this in spec/spec_helper.rb instead
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:confirmed_user, name: "Avery Admin").tap { |user| user.add_role(:admin) } }
  let(:person) { create(:confirmed_user, name: "Alex Example", email: "alex@example.com") }
  let(:authority) { create(:authority, full_name: "Exampleton City Council") }
  let(:application) do
    create(:geocoded_application, authority:, council_reference: "DA-2026/123",
                                  description: "Build a granny flat")
  end
  let(:comment) do
    create(:published_comment, application:, user: person, name: "Alex Example",
                               text: "Please consider the parking")
  end
  let(:report) { create(:report, comment:, details: "This comment is abusive") }
  let(:api_key) { create(:api_key, user: person) }

  before { sign_in admin }

  def expect_working_admin_page
    expect(response).to have_http_status(:ok)
    expect(response).to have_no_broken_internal_links
    expect(response).to have_no_missing_assets
  end

  it "has the admin home page" do
    get admin_root_path

    expect_working_admin_page
    expect(response.body).to include("Administration Panel")
  end

  describe "applications" do
    before { application }

    it "lists them" do
      get admin_applications_path

      expect_working_admin_page
      expect(response.body).to include("DA-2026/123", "Exampleton City Council")
    end

    it "shows one" do
      get admin_application_path(application)

      expect_working_admin_page
      expect(response.body).to include("DA-2026/123", "Build a granny flat")
    end

    it "edits one" do
      get edit_admin_application_path(application)

      expect_working_admin_page
      expect(response.body).to include("Edit DA-2026/123")
    end
  end

  describe "authorities" do
    before { authority }

    it "lists them" do
      get admin_authorities_path

      expect_working_admin_page
      expect(response.body).to include("Exampleton City Council")
    end

    it "shows one" do
      get admin_authority_path(authority)

      expect_working_admin_page
      expect(response.body).to include("Exampleton City Council")
    end

    it "edits one" do
      get edit_admin_authority_path(authority)

      expect_working_admin_page
      expect(response.body).to include("Edit Exampleton City Council")
    end

    it "has a form for a new one" do
      get new_admin_authority_path

      expect_working_admin_page
      # administrate 0.20 titles this page with the plural, "New Authorities"
      expect(response.body).to include("New Authorit", "Full name")
    end
  end

  describe "comments" do
    before { comment }

    it "lists them" do
      get admin_comments_path

      expect_working_admin_page
      expect(response.body).to include("Please consider the parking")
    end

    it "shows one" do
      get admin_comment_path(comment)

      expect_working_admin_page
      expect(response.body).to include("Please consider the parking", "Alex Example")
    end

    it "edits one" do
      get edit_admin_comment_path(comment)

      expect_working_admin_page
      expect(response.body).to include("Please consider the parking")
    end
  end

  describe "reports" do
    before { report }

    it "lists them" do
      get admin_reports_path

      expect_working_admin_page
      expect(response.body).to include("This comment is abusive")
    end

    it "shows one" do
      get admin_report_path(report)

      expect_working_admin_page
      expect(response.body).to include("This comment is abusive")
    end
  end

  describe "users" do
    before { person }

    it "lists them" do
      get admin_users_path

      expect_working_admin_page
      expect(response.body).to include("alex@example.com")
    end

    it "shows one" do
      get admin_user_path(person)

      expect_working_admin_page
      expect(response.body).to include("Alex Example", "alex@example.com")
    end

    it "edits one" do
      get edit_admin_user_path(person)

      expect_working_admin_page
      expect(response.body).to include("Edit Alex Example")
    end
  end

  describe "API keys" do
    before { api_key }

    it "lists them" do
      get admin_api_keys_path

      expect_working_admin_page
      expect(response.body).to include("Alex Example")
    end

    it "shows one" do
      get admin_api_key_path(api_key)

      expect_working_admin_page
      expect(response.body).to include("ApiKey ##{api_key.id} (alex@example.com)")
    end

    it "edits one" do
      get edit_admin_api_key_path(api_key)

      expect_working_admin_page
      expect(response.body).to include("Edit ApiKey ##{api_key.id} (alex@example.com)")
    end
  end

  it "lists the top API users" do
    DailyApiUsage.create!(api_key:, date: Time.zone.today, count: 42)

    get admin_api_usages_path(period: 30)

    expect_working_admin_page
    expect(response.body).to include("Top 50 users of the API", "Alex Example", "alex@example.com", "42")
  end

  it "has the background jobs page" do
    get admin_background_jobs_path

    expect_working_admin_page
    # The page embeds the Sidekiq dashboard
    expect(response.body).to include('<iframe src="/admin/jobs"')
  end

  describe "roles" do
    let(:role) { Role.find_by!(name: "admin") }

    before { admin }

    it "lists them" do
      get admin_roles_path

      expect_working_admin_page
      # The index shows how many people have each role, not who
      expect(response.body).to include("admin", "1 user")
    end

    it "shows one" do
      get admin_role_path(role)

      expect_working_admin_page
      expect(response.body).to include("admin", "Avery Admin")
    end
  end
end
