# frozen_string_literal: true

require "spec_helper"

describe "Extra options on address search" do
  before do
    Flipper.enable(:extra_options_on_address_search)
    mock_geocoder_valid_address_response
    create(:geocoded_application, lat: -33.772607, lng: 150.624245,
                                  lonlat: RGeo::Geographic.spherical_factory(srid: 4326).point(150.624245, -33.772607),
                                  description: "Build a granny flat")
  end

  it "lets people choose how far back to look when sorted by distance" do
    get address_applications_path(q: "24 Bruce Road, Glenbrook", sort: "distance")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("within the last", "3 months", "6 months", "year", "2 years", "5 years",
                                     "10 years", "Build a granny flat")
  end

  it "only shows applications from the time chosen" do
    create(:geocoded_application, lat: -33.772607, lng: 150.624245,
                                  lonlat: RGeo::Geographic.spherical_factory(srid: 4326).point(150.624245, -33.772607),
                                  description: "Build an old shed", date_scraped: 200.days.ago)

    get address_applications_path(q: "24 Bruce Road, Glenbrook", sort: "distance", time: 365 / 4)

    expect(response.body).to include("Build a granny flat")
    expect(response.body).not_to include("Build an old shed")
  end
end
