# frozen_string_literal: true

require "spec_helper"

describe ApiController do
  render_views

  shared_examples "an authenticated API" do
    shared_examples "not authorised" do
      it { expect(subject.status).to eq 401 }
      it { expect(subject.body).to eq '{"error":"not authorised - use a valid api key"}' }
    end

    context "when no API key is given" do
      subject { get method, params: params.merge(key: nil) }

      include_examples "not authorised"
    end

    context "when invalid API key is given" do
      subject { get method, params: params.merge(key: "jsdfhsd") }

      include_examples "not authorised"
    end

    context "when user has API access disabled" do
      subject do
        key = create(:api_key, disabled: true)
        get method, params: params.merge(key: key.value)
      end

      include_examples "not authorised"
    end
  end

  let(:key) { create(:api_key) }

  describe "#all" do
    describe "rss" do
      it "does not support rss" do
        key.update(bulk: true)
        expect { get :all, params: { format: "rss", key: key.value } }.to raise_error ActionController::UnknownFormat
      end
    end

    describe "json" do
      it_behaves_like "an authenticated API" do
        let(:method) { :all }
        let(:params) { { format: "js" } }
      end

      it "errors if valid api key is given but no bulk api access" do
        result = create(:geocoded_application, id: 10, date_scraped: Time.utc(2001, 1, 1))
        # rubocop:disable RSpec/MessageChain
        allow(Application).to receive_message_chain(:where, :paginate).and_return([result])
        # rubocop:enable RSpec/MessageChain
        get :all, params: { key: key.value, format: "js" }
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq('{"error":"no bulk api access"}')
      end

      it "finds recent applications if api key is given" do
        key.update(bulk: true)
        authority = create(:authority, full_name: "Acme Local Planning Authority")
        result = create(:geocoded_application, id: 10, date_scraped: Time.utc(2001, 1, 1), authority:)
        # rubocop:disable RSpec/MessageChain
        allow(Application).to receive_message_chain(:where, :paginate).and_return([result])
        # rubocop:enable RSpec/MessageChain
        get :all, params: { key: key.value, format: "js" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(
          "application_count" => 1,
          "max_id" => 10,
          "applications" => [{
            "application" => {
              "id" => 10,
              "council_reference" => "001",
              "address" => "A test address",
              "description" => "Pretty",
              "info_url" => "http://foo.com",
              "comment_url" => nil,
              "lat" => 1.0,
              "lng" => 2.0,
              "date_scraped" => "2001-01-01T00:00:00.000Z",
              "date_received" => nil,
              "on_notice_from" => nil,
              "on_notice_to" => nil,
              "authority" => {
                "full_name" => "Acme Local Planning Authority"
              }
            }
          }]
        )
      end
    end
  end

  describe "#suburb_postcode" do
    # TODO: Make errors work with rss format
    it_behaves_like "an authenticated API" do
      let(:method) { :suburb_postcode }
      let(:params) { { format: "js", postcode: "2780" } }
    end

    it_behaves_like "an authenticated API" do
      let(:method) { :suburb_postcode }
      let(:params) { { format: "js", suburb: "Katoomba" } }
    end

    it "finds recent applications for a postcode" do
      result = Application.none
      scope1 = Application.none
      scope2 = Application.none
      scope3 = Application.none
      scope4 = Application.none
      allow(Application).to receive(:order).and_return(scope1)
      allow(scope1).to receive(:where).with(postcode: "2780").and_return(scope2)
      allow(scope2).to receive(:includes).and_return(scope3)
      allow(scope3).to receive(:page).with(nil).and_return(scope4)
      allow(scope4).to receive(:per).with(100).and_return(result)
      get :suburb_postcode, params: { key: key.value, format: "rss", postcode: "2780" }
      expect(assigns[:applications]).to eq(result)
      expect(assigns[:description]).to eq("Recent applications in 2780")
    end

    it "supports json api version 1" do
      authority = create(:authority, full_name: "Acme Local Planning Authority")
      application = create(:geocoded_application, id: 10, date_scraped: Time.utc(2001, 1, 1), authority:)
      result = Application.where(id: application.id)
      scope1 = Application.none
      scope2 = Application.none
      scope3 = Application.none
      scope4 = Application.none
      allow(result).to receive(:total_pages).and_return(5)
      allow(Application).to receive(:order).and_return(scope1)
      allow(scope1).to receive(:where).and_return(scope2)
      allow(scope2).to receive(:includes).and_return(scope3)
      allow(scope3).to receive(:page).and_return(scope4)
      allow(scope4).to receive(:per).and_return(result)
      get :suburb_postcode, params: { key: key.value, format: "js", postcode: "2780" }
      expect(JSON.parse(response.body)).to eq(
        [{
          "application" => {
            "id" => 10,
            "council_reference" => "001",
            "address" => "A test address",
            "description" => "Pretty",
            "info_url" => "http://foo.com",
            "comment_url" => nil,
            "lat" => 1.0,
            "lng" => 2.0,
            "date_scraped" => "2001-01-01T00:00:00.000Z",
            "date_received" => nil,
            "on_notice_from" => nil,
            "on_notice_to" => nil,
            "authority" => {
              "full_name" => "Acme Local Planning Authority"
            }
          }
        }]
      )
    end

    it "supports json api version 2" do
      authority = create(:authority, full_name: "Acme Local Planning Authority")
      application = create(:geocoded_application, id: 10, date_scraped: Time.utc(2001, 1, 1), authority:)
      result = Application.where(id: application.id)
      scope1 = Application.none
      scope2 = Application.none
      scope3 = Application.none
      scope4 = Application.none
      allow(result).to receive(:total_pages).and_return(5)
      allow(Application).to receive(:order).and_return(scope1)
      allow(scope1).to receive(:where).and_return(scope2)
      allow(scope2).to receive(:includes).and_return(scope3)
      allow(scope3).to receive(:page).and_return(scope4)
      allow(scope4).to receive(:per).and_return(result)
      get :suburb_postcode, params: { key: key.value, format: "js", v: "2", postcode: "2780" }
      expect(JSON.parse(response.body)).to eq(
        "application_count" => 1,
        "page_count" => 5,
        "applications" => [{
          "application" => {
            "id" => 10,
            "council_reference" => "001",
            "address" => "A test address",
            "description" => "Pretty",
            "info_url" => "http://foo.com",
            "comment_url" => nil,
            "lat" => 1.0,
            "lng" => 2.0,
            "date_scraped" => "2001-01-01T00:00:00.000Z",
            "date_received" => nil,
            "on_notice_from" => nil,
            "on_notice_to" => nil,
            "authority" => {
              "full_name" => "Acme Local Planning Authority"
            }
          }
        }]
      )
    end

    it "supports geojson" do
      authority = create(:authority, full_name: "Acme Local Planning Authority")
      application = create(:geocoded_application, id: 10, date_scraped: Time.utc(2001, 1, 1), authority:)
      result = Application.where(id: application.id)
      scope1 = Application.none
      scope2 = Application.none
      scope3 = Application.none
      scope4 = Application.none
      allow(result).to receive(:total_pages).and_return(5)
      allow(Application).to receive(:order).and_return(scope1)
      allow(scope1).to receive(:where).and_return(scope2)
      allow(scope2).to receive(:includes).and_return(scope3)
      allow(scope3).to receive(:page).and_return(scope4)
      allow(scope4).to receive(:per).and_return(result)
      get :suburb_postcode, params: { key: key.value, format: "geojson", postcode: "2780" }
      expect(JSON.parse(response.body)).to eq(
        "type" => "FeatureCollection",
        "features" => [
          {
            "type" => "Feature",
            "geometry" => { "type" => "Point", "coordinates" => [2.0, 1.0] },
            "properties" => {
              "id" => 10,
              "council_reference" => "001",
              "address" => "A test address",
              "description" => "Pretty",
              "info_url" => "http://foo.com",
              "comment_url" => nil,
              "date_scraped" => "2001-01-01T00:00:00.000Z",
              "date_received" => nil,
              "on_notice_from" => nil,
              "on_notice_to" => nil,
              "authority" => {
                "full_name" => "Acme Local Planning Authority"
              }
            }
          }
        ]
      )
    end

    it "finds recent applications for a suburb" do
      result = Application.none
      scope1 = Application.none
      scope2 = Application.none
      scope3 = Application.none
      scope4 = Application.none
      allow(Application).to receive(:order).and_return(scope1)
      allow(scope1).to receive(:where).with(suburb: "Katoomba").and_return(scope2)
      allow(scope2).to receive(:includes).and_return(scope3)
      allow(scope3).to receive(:page).with(nil).and_return(scope4)
      allow(scope4).to receive(:per).with(100).and_return(result)
      get :suburb_postcode, params: { key: key.value, format: "rss", suburb: "Katoomba" }
      expect(assigns[:applications]).to eq(result)
      expect(assigns[:description]).to eq("Recent applications in Katoomba")
    end

    describe "search by suburb and state" do
      it "finds recent applications for a suburb and state" do
        result = Application.none
        scope1 = Application.none
        scope2 = Application.none
        scope3 = Application.none
        scope4 = Application.none
        scope5 = Application.none
        allow(Application).to receive(:order).and_return(scope1)
        allow(scope1).to receive(:where).with(suburb: "Katoomba").and_return(scope2)
        allow(scope2).to receive(:where).with(state: "NSW").and_return(scope3)
        allow(scope3).to receive(:includes).and_return(scope4)
        allow(scope4).to receive(:page).with(nil).and_return(scope5)
        allow(scope5).to receive(:per).with(100).and_return(result)
        get :suburb_postcode, params: { key: key.value, format: "rss", suburb: "Katoomba", state: "NSW" }
        expect(assigns[:applications]).to eq(result)
        expect(assigns[:description]).to eq("Recent applications in Katoomba, NSW")
      end
    end

    describe "search by suburb, state and postcode" do
      it "finds recent applications for a suburb, state and postcode" do
        result = Application.none
        scope1 = Application.none
        scope2 = Application.none
        scope3 = Application.none
        scope4 = Application.none
        scope5 = Application.none
        scope6 = Application.none
        allow(Application).to receive(:order).and_return(scope1)
        allow(scope1).to receive(:where).with(suburb: "Katoomba").and_return(scope2)
        allow(scope2).to receive(:where).with(state: "NSW").and_return(scope3)
        allow(scope3).to receive(:where).with(postcode: "2780").and_return(scope4)
        allow(scope4).to receive(:includes).and_return(scope5)
        allow(scope5).to receive(:page).with(nil).and_return(scope6)
        allow(scope6).to receive(:per).with(100).and_return(result)
        get :suburb_postcode, params: { key: key.value, format: "rss", suburb: "Katoomba", state: "NSW", postcode: "2780" }
        expect(assigns[:applications]).to eq(result)
        expect(assigns[:description]).to eq("Recent applications in Katoomba, NSW, 2780")
      end
    end
  end

  describe "#point" do
    # Calls using address are no longer supported. See
    # https://github.com/openaustralia/planningalerts/issues/1356
    let(:result) { Application.none }

    before do
      scope1 = Application.none
      scope2 = Application.none
      scope3 = Application.none
      scope4 = Application.none

      allow(Application).to receive(:where).and_return(scope1)
      allow(scope1).to receive(:reorder).and_return(scope2)
      allow(scope2).to receive(:includes).and_return(scope3)
      allow(scope3).to receive(:page).and_return(scope4)
      allow(scope4).to receive(:per).and_return(result)
    end

    it "errors when using deprecated API call" do
      get :point, params: { format: "rss", address: "24 Bruce Road Glenbrook" }
      expect(response.body).to eq("Bad request: Invalid parameter(s) used: address")
      expect(response).to have_http_status(:bad_request)
    end

    it_behaves_like "an authenticated API" do
      let(:method) { :point }
      let(:params) { { format: "js", lat: 1.0, lng: 2.0 } }
    end

    it "finds recent applications near the point" do
      get :point, params: { key: key.value, format: "rss", lat: 1.0, lng: 2.0, radius: 4000 }
      expect(assigns[:applications]).to eq(result)
      expect(assigns[:description]).to eq("Recent applications within 4 kilometres of 1.0,2.0")
    end

    it "finds recent applications near the point using the old parameter name" do
      get :point, params: { key: key.value, format: "rss", lat: 1.0, lng: 2.0, area_size: 4000 }
      expect(assigns[:applications]).to eq(result)
      expect(assigns[:description]).to eq("Recent applications within 4 kilometres of 1.0,2.0")
    end

    it "uses a search radius of 2000 when none is specified" do
      get :point, params: { key: key.value, format: "rss", lat: 1.0, lng: 2.0 }
      expect(assigns[:applications]).to eq(result)
      expect(assigns[:description]).to eq("Recent applications within 2 kilometres of 1.0,2.0")
    end

    it "logs the api call" do
      Timecop.freeze do
        # There is some truncation that happens in the serialisation
        expected_time = Time.at(Time.zone.now.to_f).utc
        allow(LogApiCallService).to receive(:call)
        Sidekiq::Testing.inline! do
          get :point, params: { key: key.value, format: "rss", lat: 1.0, lng: 2.0, radius: 4000 }
        end
        expect(LogApiCallService).to have_received(:call).with(
          time: expected_time,
          key:,
          ip_address: "0.0.0.0",
          query: "/applications.rss?key=#{CGI.escape(key.value)}&lat=1.0&lng=2.0&radius=4000",
          params: {
            "controller" => "api",
            "action" => "point",
            "format" => "rss",
            "lat" => "1.0",
            "lng" => "2.0",
            "key" => key.value,
            "radius" => "4000"
          },
          user_agent: "Rails Testing"
        )
      end
    end
  end

  describe "#area" do
    it_behaves_like "an authenticated API" do
      let(:method) { :area }
      let(:params) do
        { format: "js", bottom_left_lat: 1.0, bottom_left_lng: 2.0,
          top_right_lat: 3.0, top_right_lng: 4.0 }
      end
    end

    it "finds recent applications in an area" do
      result = Application.none
      scope1 = Application.none
      scope2 = Application.none
      scope3 = Application.none
      scope4 = Application.none
      allow(Application).to receive(:order).and_return(scope1)
      allow(scope1).to receive(:where).with(lat: "1.0".."3.0", lng: "2.0".."4.0").and_return(scope2)
      allow(scope2).to receive(:includes).and_return(scope3)
      allow(scope3).to receive(:page).with(nil).and_return(scope4)
      allow(scope4).to receive(:per).with(100).and_return(result)

      get :area, params: {
        key: key.value,
        format: "rss",
        bottom_left_lat: 1.0,
        bottom_left_lng: 2.0,
        top_right_lat: 3.0,
        top_right_lng: 4.0
      }
      expect(assigns[:applications]).to eq(result)
      expect(assigns[:description]).to eq("Recent applications in the area (1.0,2.0) (3.0,4.0)")
    end
  end

  describe "#authority" do
    it_behaves_like "an authenticated API" do
      let(:method) { :authority }
      let(:params) { { format: "js", authority_id: "blue_mountains" } }
    end

    it "finds recent applications for an authority" do
      authority = build(:authority, full_name: "Blue Mountains City Council", state: "NSW")
      result = Application.none
      scope1 = Application.none
      scope2 = Application.none
      scope3 = Application.none

      allow(Authority).to receive(:find_short_name_encoded).with("blue_mountains").and_return(authority)
      allow(authority).to receive(:applications).and_return(scope1)
      allow(scope1).to receive(:includes).and_return(scope2)
      allow(scope2).to receive(:page).with(nil).and_return(scope3)
      allow(scope3).to receive(:per).with(100).and_return(result)

      get :authority, params: { key: key.value, format: "rss", authority_id: "blue_mountains" }
      expect(assigns[:applications]).to eq(result)
      expect(assigns[:description]).to eq("Recent applications from Blue Mountains City Council, NSW")
    end
  end

  describe "#date_scraped" do
    it_behaves_like "an authenticated API" do
      let(:method) { :date_scraped }
      let(:params) { { format: "js", date_scraped: "2015-05-06" } }
    end

    context "when valid api key is given but no bulk api access" do
      subject(:page) { get :date_scraped, params: { key: create(:api_key).value, format: "js", date_scraped: "2015-05-06" } }

      it { expect(page.status).to eq 401 }
      it { expect(page.body).to eq '{"error":"no bulk api access"}' }
    end

    context "with valid authentication" do
      subject(:page) { get :date_scraped, params: { key: key.value, format: "js", date_scraped: "2015-05-06" } }

      let(:key) { create(:api_key, bulk: true) }

      before do
        5.times do
          create(:geocoded_application, date_scraped: Time.utc(2015, 5, 5, 12, 0, 0))
          create(:geocoded_application, date_scraped: Time.utc(2015, 5, 6, 12, 0, 0))
        end
      end

      it { expect(page).to be_successful }
      it { expect(JSON.parse(page.body).count).to eq 5 }

      context "when invalid date" do
        subject(:page) { get :date_scraped, params: { key: key.value, format: "js", date_scraped: "foobar" } }

        it { expect(page).not_to be_successful }
        it { expect(page.body).to eq '{"error":"invalid date_scraped"}' }
      end
    end
  end
end
