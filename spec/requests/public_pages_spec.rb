# frozen_string_literal: true

require "spec_helper"

# Smoke tests for public pages that no other spec renders
describe "Public pages" do
  # TODO: #2166 Include this in spec/spec_helper.rb instead
  include Devise::Test::IntegrationHelpers

  def expect_working_page(status: :ok)
    expect(response).to have_http_status(status)
    # Rails' default security headers, which framework default upgrades can change
    expect(response.headers).to include(
      "X-Frame-Options" => "SAMEORIGIN",
      "X-Content-Type-Options" => "nosniff",
      "X-Permitted-Cross-Domain-Policies" => "none",
      "Referrer-Policy" => "strict-origin-when-cross-origin"
    )
    expect(response).to have_site_layout
    expect(response).to have_no_broken_internal_links
    expect(response).to have_no_missing_assets
  end

  describe "most commented applications" do
    it "lists recent applications with comments" do
      application = create(:geocoded_application, address: "12 Example Street, Exampleton NSW 2000",
                                                  description: "Build a granny flat")
      create(:published_comment, application:)

      get trending_applications_path

      expect_working_page
      expect(response.body).to include("Top 20 most commented", "Journalist?")
      expect(response.body).to include("12 Example Street", "Build a granny flat")
    end
  end

  describe "application history" do
    it "shows what changed between versions" do
      Flipper.enable(:view_application_versions)
      application = create(:geocoded_application, description: "Build a shed")
      CreateOrUpdateApplicationService.call(
        authority: application.authority,
        council_reference: application.council_reference,
        attributes: { date_scraped: Time.current, description: "Build a bigger shed" }
      )

      get application_versions_path(application)

      expect_working_page
      expect(response.body).to include("History", "Description", "Build a bigger shed")
    end
  end

  describe "under the hood for an authority" do
    it "shows the scraper and its latest import log" do
      authority = create(:authority, full_name: "Exampleton City Council",
                                     morph_name: "planningalerts-scrapers/exampleton",
                                     last_scraper_run_log: "Imported 3 applications")

      get authority_under_the_hood_path(authority.short_name_encoded)

      expect_working_page
      expect(response.body).to include("Under the hood", "Exampleton City Council", "Most recent import logs")
      expect(response.body).to include("planningalerts-scrapers/exampleton", "Imported 3 applications")
    end
  end

  describe "geocoding comparison" do
    let!(:geocode_query) do
      query = GeocodeQuery.create!(query: "12 Example Street, Exampleton NSW 2000")
      query.geocode_results.create!(geocoder: "google", lat: -33.8, lng: 151.2,
                                    full_address: "12 Example St, Exampleton NSW 2000")
      query.geocode_results.create!(geocoder: "mappify", lat: -33.81, lng: 151.21,
                                    full_address: "12 Example Street, Exampleton NSW 2000")
      query
    end

    it "lists the queries" do
      get geocode_queries_path

      expect_working_page
      expect(response.body).to include("Addresses with significant differences in geocoded results")
      expect(response.body).to include("12 Example Street, Exampleton NSW 2000", "12 Example St, Exampleton NSW 2000")
    end

    it "shows both geocoders' results for one query" do
      get geocode_query_path(geocode_query)

      expect_working_page
      expect(response.body).to include("Google address", "Mappify address")
      expect(response.body).to include("12 Example St, Exampleton NSW 2000", "12 Example Street, Exampleton NSW 2000")
    end
  end

  describe "API key pages" do
    describe "with the API key request pages switched on" do
      before { Flipper.enable(:request_api_keys) }

      it "explains the paid service" do
        get new_api_keys_request_path

        expect_working_page
        expect(response.body).to include("Request an API key", "The Planning Alerts API is a paid service")
      end

      it "has the non-commercial request form" do
        pending "#2352 its form posts to a route that doesn't exist"
        get new_api_keys_non_commercial_path

        expect_working_page
        expect(response.body).to include("Request a non-commercial API key", "Terms of use")
      end

      it "has the paid sign-up form" do
        pending "#2352 its form posts to a route that doesn't exist"
        get new_api_keys_paid_path

        expect_working_page
        expect(response.body).to include("Sign up for access to the API key")
      end
    end

    describe "when signed in" do
      let(:user) { create(:confirmed_user) }

      before { sign_in user }

      it "lists the person's API keys" do
        api_key = create(:api_key, user:)

        get api_keys_path

        expect_working_page
        expect(response.body).to include("Your API keys", "Plan type:", api_key.value)
      end

      it "shows when a trial key expires" do
        create(:api_key, user:, expires_at: 14.days.from_now)

        get api_keys_path

        expect_working_page
        expect(response.body).to match(%r{Expires in:\s*<time datetime="[^"]+" title="[^"]+">14 days</time>})
      end

      it "says when the trial is over" do
        create(:api_key, user:, expires_at: 1.day.ago)

        get api_keys_path

        expect_working_page
        expect(response.body).to include("Key expired", "Your trial access to our API is up!")
      end

      it "confirms creating a key" do
        get confirm_api_keys_path

        expect_working_page
        expect(response.body).to include("Create API key")
      end
    end
  end

  describe "how to write a scraper" do
    it "has the guide" do
      get how_to_write_a_scraper_path

      expect_working_page
      expect(response.body).to include("How to write a scraper")
    end
  end

  describe "documentation pages" do
    {
      get_involved_path: "Get Involved",
      how_to_lobby_your_local_council_path: "How to lobby your local council to publish better planning data",
      api_howto_path: "Who uses our API?",
      api_developer_path: "API developer documentation"
    }.each do |path, heading|
      it "has #{path.to_s.delete_suffix('_path').humanize.downcase}" do
        get public_send(path)

        expect_working_page
        expect(response.body).to include(heading)
      end
    end
  end

  describe "error pages" do
    it "has the not found page" do
      get "/404"

      expect_working_page(status: :not_found)
      expect(response.body).to include("404 - Not Found")
    end

    it "has the server error page" do
      get "/500"

      expect_working_page(status: :internal_server_error)
      expect(response.body).to include("sorry, but something went wrong (500)")
    end
  end

  describe "an authority's recent activity" do
    let(:authority) { create(:authority, full_name: "Exampleton City Council") }
    let(:application) do
      create(:geocoded_application, authority:, address: "12 Example Street, Exampleton NSW 2000",
                                    description: "Build a granny flat")
    end

    it "lists its applications" do
      application

      get authority_applications_path(authority.short_name_encoded)

      expect_working_page
      expect(response.body).to include("Exampleton City Council", "12 Example Street", "Build a granny flat")
    end

    it "lists comments on its applications" do
      create(:published_comment, application:, text: "Please consider the parking")

      get authority_comments_path(authority.short_name_encoded)

      expect_working_page
      expect(response.body).to include("All recent comments on applications from Exampleton City Council, NSW",
                                       "Please consider the parking")
    end
  end

  describe "full text search" do
    it "has the search form" do
      Flipper.enable(:full_text_search)

      get search_applications_path

      expect_working_page
      expect(response.body).to include("Search")
    end
  end

  describe "account pages" do
    it "has the sign in form" do
      get new_user_session_path

      expect_working_page
      expect(response.body).to include("New to Planning Alerts?")
    end

    it "has the sign up form" do
      get new_user_registration_path

      expect_working_page
      expect(response.body).to include("Create an account")
    end

    it "has the form to resend unlock instructions" do
      get new_user_unlock_path

      expect_working_page
      expect(response.body).to include("Resend unlock instructions")
    end

    it "has the form to start activating an account" do
      get new_users_activation_path

      expect_working_page
      expect(response.body).to include("Activate your account")
    end

    it "has the form to finish activating an account" do
      get edit_users_activation_path(token: "a-token-from-the-email")

      expect_working_page
      expect(response.body).to include("Activate your account")
    end

    describe "when signed in" do
      let(:user) { create(:confirmed_user, name: "Alex Example", email: "alex@example.com") }

      before { sign_in user }

      it "edits the account" do
        get edit_user_registration_path

        expect_working_page
        expect(response.body).to include("Edit your account", "alex@example.com")
      end

      it "has the form for a new alert" do
        get new_alert_path

        expect_working_page
        expect(response.body).to include("Create new alert")
      end

      it "reports a comment" do
        comment = create(:published_comment, text: "Please consider the parking")

        get new_comment_report_path(comment)

        expect_working_page
        expect(response.body).to include("Report a comment", "Please consider the parking")
      end
    end
  end

  describe "creating an account to save a search" do
    it "has the sign up form for the alert" do
      get new_alerts_user_registration_path(user: { address: "12 Example Street, Exampleton NSW 2000", radius_meters: 2000 })

      expect_working_page
      expect(response.body).to include("Create an account to save this search", "12 Example Street, Exampleton NSW 2000")
    end
  end

  describe "signing in to save a search" do
    it "has the sign in form for the alert" do
      get new_alerts_user_session_path(user: { address: "12 Example Street, Exampleton NSW 2000", radius_meters: 2000 })

      expect_working_page
      expect(response.body).to include("12 Example Street, Exampleton NSW 2000")
    end
  end
end
