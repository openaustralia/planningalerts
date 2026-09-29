# frozen_string_literal: true

require "spec_helper"

describe "API hostnames" do
  let(:key) { create(:api_key) }

  before { allow(LogApiCallService).to receive(:call) }

  %w[api.planningalerts.org.au api-idle.planningalerts.org.au api.pa.org.localhost].each do |host|
    describe "on #{host}" do
      let(:website) { host.sub("api", "www") }

      before { host! host }

      it "serves the API" do
        get "/authorities.json", params: { key: key.value }
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq "application/json"
      end

      it "links RSS items to the website, not the API hostname" do
        application = create(:application, postcode: "2000")
        get "/applications.rss", params: { postcode: "2000", key: key.value }
        expect(response.body).to include "<link>http://#{website}/</link>"
        expect(response.body).to include "http://#{website}/applications/#{application.id}?"
      end

      it "leaves rejecting a missing key to the API" do
        get "/applications.js"
        expect(response).to have_http_status(:unauthorized)
      end

      it "redirects the home page to the website" do
        get "/"
        expect(response).to redirect_to "http://#{website}/"
        expect(response).to have_http_status(:moved_permanently)
      end

      it "redirects application pages to the website, keeping the query string" do
        get "/applications/123", params: { utm_source: "feed", utm_medium: "rss" }
        expect(response).to redirect_to "http://#{website}/applications/123?utm_source=feed&utm_medium=rss"
        expect(response).to have_http_status(:moved_permanently)
      end

      %w[/faq /applications /applications/123/versions /applications/address /admin /profile/alerts /users/sign_in].each do |path|
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

  %w[www.planningalerts.org.au planningalerts.org.au localhost].each do |host|
    describe "on #{host}" do
      before { host! host }

      it "serves the website" do
        get "/faq"
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq "text/html"
      end

      # The API routes come first but need a format, so these web pages
      # sharing their paths must still reach the website
      it "serves the applications page" do
        get "/applications"
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq "text/html"
      end

      it "serves an authority's applications page" do
        authority = create(:authority)
        get "/authorities/#{authority.short_name_encoded}/applications"
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq "text/html"
      end

      it "serves the API" do
        get "/authorities.json", params: { key: key.value }
        expect(response).to have_http_status(:ok)
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
