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

  # Geocode results are cached for a day. This uses a file store, which
  # serialises entries in the configured cache format like Memcached does in
  # production, so a change of format in a Rails upgrade shows up here.
  describe "with the real geocoder and a cache" do
    include WebMock::API

    let(:google_reply) do
      {
        status: "OK",
        results: [{
          formatted_address: "24 Bruce Rd, Glenbrook NSW 2773, Australia",
          geometry: { location: { lat: -33.772607, lng: 150.624245 }, location_type: "ROOFTOP" },
          address_components: [
            { long_name: "Glenbrook", short_name: "Glenbrook", types: ["locality"] },
            { long_name: "New South Wales", short_name: "NSW", types: ["administrative_area_level_1"] },
            { long_name: "2773", short_name: "2773", types: ["postal_code"] },
            { long_name: "Australia", short_name: "AU", types: ["country"] }
          ]
        }]
      }.to_json
    end

    before do
      allow(GoogleGeocodeService).to receive(:call).and_call_original
      allow(Rails.configuration.x.google_maps).to receive(:server_key).and_return("example-key")
      allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::FileStore.new(Dir.mktmpdir))
      stub_request(:get, %r{\Ahttps://maps.googleapis.com/maps/api/geocode/json})
        .to_return(body: google_reply, headers: { "Content-Type" => "application/json" })
      allow(HTTParty).to receive(:get).and_call_original
    end

    it "asks Google once, then reuses the cached result" do
      2.times do
        get address_applications_path(q: "24 Bruce Road, Glenbrook", sort: "distance")
        expect(response.body).not_to include("Sorry")
        expect(response.body).to include("Build a granny flat")
      end

      expect(HTTParty).to have_received(:get).with(%r{\Ahttps://maps.googleapis.com/}).once
    end
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
