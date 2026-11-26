# frozen_string_literal: true

require "spec_helper"

# So response.parsed_body reads GeoJSON as the JSON it is
ActionDispatch::IntegrationTest.register_encoder :geojson, response_parser: ->(body) { JSON.parse(body) }

# Every format the API answers in, through the real API hostname and routes.
# The controller spec mostly uses the deprecated .js format, so this makes sure
# the .json, .geojson and .rss responses customers rely on are rendered too.
describe "API formats" do
  let(:key) { create(:api_key) }
  let(:authority) { create(:authority, full_name: "Exampleton City Council") }
  let!(:application) do
    create(:geocoded_application, authority:, council_reference: "DA-2026/123", postcode: "2000",
                                  address: "12 Example Street, Exampleton NSW 2000", description: "Build a granny flat")
  end

  before do
    allow(LogApiCallService).to receive(:call)
    host! "api.planningalerts.org.au"
  end

  def json = response.parsed_body

  describe "applications" do
    it "answers .json with a list of applications" do
      get "/applications.json", params: { key: key.value, postcode: "2000" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq "application/json"
      expect(json).to contain_exactly(
        "application" => hash_including("council_reference" => "DA-2026/123", "description" => "Build a granny flat",
                                        "authority" => { "full_name" => "Exampleton City Council" })
      )
    end

    it "answers .json with page counts for version 2" do
      get "/applications.json", params: { key: key.value, postcode: "2000", v: "2" }

      expect(response).to have_http_status(:ok)
      expect(json).to include("application_count" => 1, "page_count" => 1)
      expect(json["applications"].first["application"]).to include("council_reference" => "DA-2026/123")
    end

    it "answers .js as JSON, for older clients" do
      get "/applications.js", params: { key: key.value, postcode: "2000" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq "application/json"
      expect(json.first["application"]).to include("council_reference" => "DA-2026/123")
    end

    it "answers .geojson with a feature collection" do
      get "/applications.geojson", params: { key: key.value, postcode: "2000" }

      expect(response).to have_http_status(:ok)
      expect(json).to include("type" => "FeatureCollection")
      expect(json["features"].first).to include(
        "type" => "Feature",
        "geometry" => { "type" => "Point", "coordinates" => [2.0, 1.0] },
        "properties" => hash_including("council_reference" => "DA-2026/123")
      )
    end

    it "answers .rss with a feed" do
      get "/applications.rss", params: { key: key.value, postcode: "2000" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<rss version=\"2.0\"", "12 Example Street, Exampleton NSW 2000", "Build a granny flat")
    end

    # Each way of choosing applications, in the format most customers use
    {
      "by suburb" => { suburb: "Sydney" },
      "by address" => { lat: 1.0, lng: 2.0 },
      "by area" => { bottom_left_lat: 0.5, bottom_left_lng: 1.5, top_right_lat: 1.5, top_right_lng: 2.5 }
    }.each do |name, params|
      it "finds applications #{name} as .json" do
        get "/applications.json", params: params.merge(key: key.value)

        expect(response).to have_http_status(:ok)
        expect(json.first["application"]).to include("council_reference" => "DA-2026/123")
      end
    end

    it "finds an authority's applications as .json" do
      get "/authorities/#{authority.short_name_encoded}/applications.json", params: { key: key.value }

      expect(response).to have_http_status(:ok)
      expect(json.first["application"]).to include("council_reference" => "DA-2026/123")
    end
  end

  describe "bulk keys" do
    let(:key) { create(:api_key, bulk: true) }

    it "finds applications by date scraped as .json" do
      # The factory scrapes it 10 minutes ago, which is yesterday just after midnight
      get "/applications.json", params: { key: key.value, date_scraped: application.date_scraped.to_date.to_s }

      expect(response).to have_http_status(:ok)
      expect(json.first["application"]).to include("council_reference" => "DA-2026/123")
    end

    %w[json js].each do |format|
      it "answers .#{format} with the applications and where to carry on from" do
        get "/applications.#{format}", params: { key: key.value }

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq "application/json"
        expect(json).to include("application_count" => 1, "max_id" => application.id)
        expect(json["applications"].first["application"]).to include("council_reference" => "DA-2026/123")
      end
    end
  end

  describe "authorities" do
    it "answers .json with a list of authorities" do
      get "/authorities.json", params: { key: key.value }

      expect(response).to have_http_status(:ok)
      expect(json).to include("authority" => hash_including("full_name" => "Exampleton City Council"))
    end

    it "answers .json for version 2 as well" do
      get "/authorities.json", params: { key: key.value, v: "2" }

      expect(response).to have_http_status(:ok)
      expect(json).to include("authority" => hash_including("full_name" => "Exampleton City Council"))
    end
  end

  describe "errors" do
    {
      "json" => "application/json",
      "js" => "application/json",
      "geojson" => "application/geo+json"
    }.each do |format, media_type|
      it "answers .#{format} with a JSON error for a bad key" do
        get "/applications.#{format}", params: { key: "not-a-real-key", postcode: "2000" }

        expect(response).to have_http_status(:unauthorized)
        expect(response.media_type).to eq media_type
        expect(json).to eq("error" => "not authorised - use a valid api key")
      end

      it "answers .#{format} with a JSON error for an unknown parameter" do
        get "/applications.#{format}", params: { key: key.value, postcode: "2000", colour: "blue" }

        expect(response).to have_http_status(:bad_request)
        expect(json).to eq("error" => "Bad request: Invalid parameter(s) used: colour")
      end
    end

    # The body is plain text but labelled as RSS (#2161 tracks making RSS
    # errors work properly). Tested so the upgrade can't change it unnoticed.
    it "answers .rss with a plain text error for a bad key" do
      get "/applications.rss", params: { key: "not-a-real-key", postcode: "2000" }

      expect(response).to have_http_status(:unauthorized)
      expect(response.media_type).to eq "application/rss+xml"
      expect(response.body).to eq "not authorised - use a valid api key"
    end

    it "refuses all applications to a key without bulk access" do
      get "/applications.json", params: { key: key.value }

      expect(response).to have_http_status(:unauthorized)
      expect(json).to eq("error" => "no bulk api access")
    end
  end

  describe "logging" do
    %w[json js geojson rss].each do |format|
      it "records the .#{format} format of each call" do
        get "/applications.#{format}", params: { key: key.value, postcode: "2000" }

        expect(LogApiCallService).to have_received(:call)
          .with(hash_including(params: hash_including("format" => format, "action" => "suburb_postcode")))
      end
    end
  end
end
