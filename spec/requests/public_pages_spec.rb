# frozen_string_literal: true

require "spec_helper"

# Smoke tests for public pages that no other spec renders
describe "Public pages" do
  # TODO: #2166 Include this in spec/spec_helper.rb instead
  include Devise::Test::IntegrationHelpers

  def expect_working_page
    expect(response).to have_http_status(:ok)
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

  describe "signing in to save a search" do
    it "has the sign in form for the alert" do
      get new_alerts_user_session_path(user: { address: "12 Example Street, Exampleton NSW 2000", radius_meters: 2000 })

      expect_working_page
      expect(response.body).to include("12 Example Street, Exampleton NSW 2000")
    end
  end
end
