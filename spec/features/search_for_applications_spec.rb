# frozen_string_literal: true

require "spec_helper"

describe "Searching for development application near an address" do
  around do |scenario|
    VCR.use_cassette("planningalerts") do
      scenario.run
    end
  end

  before do
    create(:geocoded_application,
           address: "24 Bruce Road Glenbrook",
           description: "A lovely house",
           lat: -33.772609,
           lng: 150.624256)
  end

  it "successfully" do
    visit root_path

    fill_in "Enter a street address", with: "24 Bruce Road, Glenbrook"
    click_button "Search"

    expect(page).to have_content "Applications within 2 kilometres of 24 Bruce Rd, Glenbrook NSW 2773"

    within "ol.applications" do
      expect(page).to have_content "24 Bruce Road"
      expect(page).to have_content "A lovely house"
    end
  end

  # Having trouble getting this to work
  # context "with javascript" do
  #   scenario "autocomplete results are displayed", js: true do
  #     visit root_path
  #
  #     fill_in "Enter a street address", with: "24 Bruce Road Glenb"
  #
  #     expect_autocomplete_suggestions_to_include "Bruce Road, Glenbrook NSW"
  #   end
  # end
end
