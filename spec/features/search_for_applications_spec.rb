# frozen_string_literal: true

require "spec_helper"

describe "Searching for development application near an address" do
  # TODO: Include this in spec/spec_helper.rb instead
  # See https://github.com/heartcombo/devise#controller-tests
  include Devise::Test::IntegrationHelpers

  before do
    create(:geocoded_application,
           address: "24 Bruce Road Glenbrook",
           description: "A lovely house",
           lat: -33.772609,
           lng: 150.624256,
           lonlat: RGeo::Geographic.spherical_factory(srid: 4326).point(150.624256, -33.772609))
    # It's more elegant to mock out the geocoder rather than using VCR
    g = GeocodedLocation.new(
      lat: -33.772607,
      lng: 150.624245,
      suburb: "Glenbrook",
      state: "NSW",
      postcode: "2773",
      full_address: "24 Bruce Rd, Glenbrook NSW 2773"
    )
    allow(GoogleGeocodeService).to receive(:call).with(address: "24 Bruce Road, Glenbrook", key: nil).and_return(GeocoderResults.new([g], nil))
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

  it "returns results in the new design" do
    sign_in create(:confirmed_user, tailwind_theme: true)
    visit root_path

    fill_in "Enter a street address", with: "24 Bruce Road, Glenbrook"
    click_button "Search"

    expect(page).to have_content "Search results"

    within "main ul" do
      expect(page).to have_content "24 Bruce Road"
      expect(page).to have_content "A lovely house"
    end
  end

  describe "accessibility tests in new design", js: true do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true)
      visit root_path

      fill_in "Enter a street address", with: "24 Bruce Road, Glenbrook"
      click_button "Search"
    end

    it "main content passes" do
      # Limiting check to main content to ignore (for the time being) colour contrast issues with the header and footer
      expect(page).to be_axe_clean.within("main")
    end

    it "page passes most" do
      # Also doing check across whole page so we catch issues like h1 not being used
      expect(page).to be_axe_clean.skipping("color-contrast")
    end
  end

  describe "accessibility tests for search applications page in new design", js: true do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true)
      visit address_applications_path
    end

    it "main content passes" do
      expect(page).to be_axe_clean.within("main")
    end

    it "mostly passes" do
      expect(page).to be_axe_clean.skipping("color-contrast")
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
