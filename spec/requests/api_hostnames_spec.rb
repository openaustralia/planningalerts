# frozen_string_literal: true

require "spec_helper"

describe "API hostnames" do
  let(:key) { create(:api_key) }

  before { allow(LogApiCallService).to receive(:call) }

  %w[api.planningalerts.org.au api-idle.planningalerts.org.au api.pa.org.localhost].each do |host|
    describe "on #{host}" do
      before { host! host }

      it "serves the API" do
        get "/authorities.json", params: { key: key.value }
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq "application/json"
      end

      it "links RSS items to the website, not the API hostname" do
        application = create(:application, postcode: "2000")
        get "/applications.rss", params: { postcode: "2000", key: key.value }
        expect(response.body).to include "<link>http://localhost/</link>"
        expect(response.body).to include "http://localhost/applications/#{application.id}?"
      end

      it "leaves rejecting a missing key to the API" do
        get "/applications.js"
        expect(response).to have_http_status(:unauthorized)
      end

      %w[/ /faq /applications /applications/1 /admin /profile/alerts /users/sign_in].each do |path|
        it "returns a plain 404 for #{path}" do
          get path
          expect(response).to have_http_status(:not_found)
          expect(response.body).to eq "Not found\n"
        end
      end

      it "returns a plain 404 for a POST to the website" do
        post "/postal/event"
        expect(response).to have_http_status(:not_found)
      end

      it "still renders error pages for failed API calls" do
        get "/404", env: { "action_dispatch.exception" => ActiveRecord::RecordNotFound.new }
        expect(response.body).not_to eq "Not found\n"
      end
    end
  end

  %w[www.planningalerts.org.au planningalerts.org.au www.pa.org.localhost localhost].each do |host|
    describe "on #{host}" do
      before { host! host }

      it "serves the website" do
        get "/faq"
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq "text/html"
      end

      ["/applications.js", "/authorities.json", "/authorities/foo/applications.rss",
       "/applications.rss?postcode=2000", "/applications.geojson?lat=-33.8&lng=151.2"].each do |path|
        it "does not serve the API at #{path}" do
          get path, params: { key: key.value }
          expect(response).to have_http_status(:not_found)
          expect(response.body).to eq "Not found\n"
        end
      end
    end
  end

  # The load balancer's health checks address each server by its IP address
  %w[api.planningalerts.org.au www.planningalerts.org.au 10.0.0.1].each do |hostname|
    it "answers health checks on #{hostname}" do
      host! hostname
      get "/health_check"
      expect(response).to have_http_status(:ok)
    end
  end
end
