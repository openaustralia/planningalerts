# frozen_string_literal: true

require "spec_helper"

describe AltchaChallengesController do
  describe "GET #show" do
    it "serves a challenge the widget can use" do
      get :show

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.keys).to contain_exactly("parameters", "signature")
    end

    # Cloudflare sits in front of production. A cached challenge would be handed
    # to everybody, and every submission after the first would look like a
    # replay.
    it "tells caches not to store the challenge" do
      get :show

      expect(response.headers["Cache-Control"]).to include("no-store")
    end

    it "serves a different challenge to each request" do
      get :show
      first = response.parsed_body["signature"]
      get :show

      expect(response.parsed_body["signature"]).not_to eq first
    end

    # Deliberately not behind a flag: a form rendered a moment before the flag
    # was switched off should still be completable.
    it "works whether or not the altcha flag is on" do
      Flipper.disable(:altcha)
      get :show

      expect(response).to have_http_status(:ok)
    end
  end
end
