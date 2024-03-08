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

    fill_in "Street address", with: "24 Bruce Road, Glenbrook"
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

      fill_in "Street address", with: "24 Bruce Road, Glenbrook"
      click_button "Search"
    end

    it "passes" do
      expect(page).to be_axe_clean
    end
  end

  describe "accessibility tests for search applications page in new design", js: true do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true, name: "Jane Ng")
      visit address_applications_path
    end

    it "passes" do
      expect(page).to be_axe_clean
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders a snapshot for a visual diff", js: true do
      page.percy_snapshot("Application search")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe "search address outside australia in new design" do
    before do
      allow(GoogleGeocodeService).to receive(:call).with(
        address: "Bruce Road, USA",
        key: nil
      ).and_return(GeocoderResults.new(
                     [],
                     "Unfortunately we only cover Australia. It looks like that address is in another country."
                   ))

      sign_in create(:confirmed_user, tailwind_theme: true, name: "Jane Ng")
      visit address_applications_path

      fill_in "Street address", with: "Bruce Road, USA"
      click_button "Search"
    end

    it "lets the user know there's a problem" do
      expect(page).to have_content("It looks like that address is in another country")
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders a snapshot for a visual diff", js: true do
      page.percy_snapshot("Application search outside Australia")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe "no results in new design" do
    before do
      # Hacky way to just remove all the applications
      ApplicationVersion.destroy_all
      Application.destroy_all

      sign_in create(:confirmed_user, tailwind_theme: true, name: "Jane Ng")
      visit address_applications_path

      fill_in "Street address", with: "24 Bruce Road, Glenbrook"
      click_button "Search"
    end

    it "lets the user know there's a problem" do
      expect(page).to have_content("Unfortunately, we don't know of any applications near 24 Bruce Rd, Glenbrook NSW 2773")
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders a snapshot for a visual diff", js: true do
      page.percy_snapshot("Application search no results")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe "search results by text in new design" do
    let(:user) { create(:confirmed_user, tailwind_theme: true, name: "Jane Ng") }

    before do
      sign_in user
      Flipper.enable :full_text_search
      # TODO: Would it be better to only enable the feature temporarily?
      visit search_applications_path
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders a snapshot for a visual diff", js: true do
      page.percy_snapshot("Application text search")
    end
    # rubocop:enable RSpec/NoExpectationExample

    describe "search with no results" do
      before do
        allow(Application).to receive(:search).and_return([])
        fill_in "q", with: "tree"
        click_button "Search"
      end

      it "lets the user know there are no results" do
        expect(page).to have_content("no results found")
      end

      # rubocop:disable RSpec/NoExpectationExample
      it "renders a snapshot for a visual diff", js: true do
        page.percy_snapshot("Application text search no results")
      end
      # rubocop:enable RSpec/NoExpectationExample
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
