# frozen_string_literal: true

require "spec_helper"

# The filters staff type into an admin index's search box, such as "hidden:"
describe "Admin index filters" do
  # TODO: #2166 Include this in spec/spec_helper.rb instead
  include Devise::Test::IntegrationHelpers

  before { sign_in(create(:confirmed_user).tap { |user| user.add_role(:admin) }) }

  def expect_filtered(path, filter, shows:, hides:)
    get path, params: { search: "#{filter}:" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(shows)
    expect(response.body).not_to include(hides)
  end

  describe "applications" do
    before do
      create(:geocoded_application, council_reference: "DA-VISIBLE")
      create(:geocoded_application, :hidden, council_reference: "DA-HIDDEN")
    end

    it("filters to visible") { expect_filtered(admin_applications_path, "visible", shows: "DA-VISIBLE", hides: "DA-HIDDEN") }
    it("filters to hidden") { expect_filtered(admin_applications_path, "hidden", shows: "DA-HIDDEN", hides: "DA-VISIBLE") }
  end

  describe "comments" do
    before do
      create(:published_comment, text: "A visible comment")
      create(:published_comment, text: "A hidden comment", hidden: true)
    end

    it("filters to visible") { expect_filtered(admin_comments_path, "visible", shows: "A visible comment", hides: "A hidden comment") }
    it("filters to hidden") { expect_filtered(admin_comments_path, "hidden", shows: "A hidden comment", hides: "A visible comment") }
  end

  describe "authorities" do
    before do
      create(:authority, full_name: "Active Council", morph_name: "planningalerts-scrapers/active", wikidata_id: "Q1000001")
      create(:authority, full_name: "Disabled Council", morph_name: "planningalerts-scrapers/disabled", disabled: true)
      create(:authority, full_name: "Unlinked Council", morph_name: "planningalerts-scrapers/unlinked")
    end

    it("filters to active") { expect_filtered(admin_authorities_path, "active", shows: "Active Council", hides: "Disabled Council") }
    it("filters to disabled") { expect_filtered(admin_authorities_path, "disabled", shows: "Disabled Council", hides: "Active Council") }

    it "filters to active ones with no Wikidata id" do
      expect_filtered(admin_authorities_path, "empty_wikidata", shows: "Unlinked Council", hides: "Active Council")
    end
  end

  describe "alerts" do
    before do
      create(:alert, address: "1 Active Street, Exampleton NSW 2000")
      create(:unsubscribed_alert, address: "2 Stopped Street, Exampleton NSW 2000")
    end

    it "filters to active" do
      expect_filtered(admin_alerts_path, "active", shows: "1 Active Street", hides: "2 Stopped Street")
    end
  end
end
