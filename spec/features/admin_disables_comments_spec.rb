# frozen_string_literal: true

require "spec_helper"

describe "Disabling comments on an application" do
  include Devise::Test::IntegrationHelpers

  let(:reason) { "Dispute is no longer productive" }

  describe "admin turns off comments" do
    before do
      create(:geocoded_application, id: 1, council_reference: "DA/2026/1")
    end

    it "successfully" do
      sign_in_as_admin

      click_on "Applications"
      click_on "Edit"

      check "Comments disabled"
      fill_in "Comments disabled reason", with: reason
      click_on "Update Application"

      expect(page).to have_content("Application was successfully updated")
      expect(page).to have_content("Comments disabled\nyes")
      expect(page).to have_content(reason)
    end
  end

  describe "viewing an application with comments disabled" do
    let(:application) { create(:geocoded_application, :comments_disabled) }

    before do
      create(:published_comment, application:, text: "An existing comment")
      sign_in(create(:confirmed_user))
      visit application_path(application)
    end

    it "keeps existing comments, replaces the form with a neutral message and hides the staff note" do
      expect(page).to have_content("An existing comment")
      expect(page).to have_content("Comments are closed on this application")
      expect(page).to have_no_button("Review and publish")
      expect(page).to have_no_content(reason)
    end
  end
end
