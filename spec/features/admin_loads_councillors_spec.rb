# frozen_string_literal: true

require "spec_helper"

feature "Admin loads councillors for an authority" do
  around do |example|
    VCR.use_cassette("planningalerts") do
      example.run
    end
  end

  given(:authority) { create(:authority, full_name: "Marrickville Council", state: "NSW") }

  scenario "successfully" do
    sign_in_as_admin

    visit admin_authority_path(authority)

    click_button "Load Councillors"

    expect(page).to have_content "Successfully loaded/updated 12 councillors"
    expect(page).to have_content "Max Phillips"
    expect(page).to have_content "Chris Woods"
  end

  context "when the authority is from another state" do
    given(:qld_authority) do
      create(:authority, full_name: "Toowoomba Regional Council", state: "QLD")
    end

    scenario "successfully" do
      sign_in_as_admin

      visit admin_authority_path(qld_authority)

      click_button "Load Councillors"

      expect(page).to have_content "Successfully loaded/updated 11 councillors"
      expect(page).to have_content "Anne Glasheen"
      expect(page).to have_content "Nancy Sommerfield"
    end
  end

  context "when councillors don’t have emails" do
    given(:gundagai) do
      create(:authority, full_name: "Gundagai Shire Council", state: "NSW")
    end

    scenario "the admin is informed they were not loaded" do
      sign_in_as_admin

      visit admin_authority_path(gundagai)

      click_button "Load Councillors"

      expect(page).to have_content "Skipped loading 8 councillors"
    end
  end

  context "when some councillors have been removed from office" do
    around do |test|
      Timecop.freeze(Time.zone.local(2016, 10, 11, 0, 0, 0)) { test.run }
    end

    given(:authority) do
      create(:authority, full_name: "Marrickville Council", state: "NSW")
    end

    scenario "they are loaded and marked as not current" do
      sign_in_as_admin

      visit admin_authority_path(authority)

      click_button "Load Councillors"

      expect(page).to have_content "Successfully loaded/updated 12 councillors"
      expect(page).to have_content "Melissa Brooks No"
    end
  end
end
