# frozen_string_literal: true

require "spec_helper"

describe WhatismyipController do
  before do
    allow(CloudflareIpRangesService).to receive(:call).and_return([IPAddr.new("173.245.48.0/20")])
  end

  describe "GET #index" do
    context "when the provide_whatismyip feature flag is off" do
      before { get :index }

      it "is not found" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the provide_whatismyip feature flag is on" do
      before do
        Flipper.enable(:provide_whatismyip)
      end

      it "returns the remote IP alone when it is outside Cloudflare's ranges" do
        request.remote_addr = "1.2.3.4"
        get :index
        expect(response.body).to eq "1.2.3.4"
      end

      it "appends FAIL when the remote IP is inside Cloudflare's ranges" do
        request.remote_addr = "173.245.48.1"
        get :index
        expect(response.body).to eq "173.245.48.1 FAIL"
      end

      context "when Cloudflare's ranges can't be determined right now" do
        before do
          allow(CloudflareIpRangesService).to receive(:call).and_return(nil)
        end

        it "appends UNABLE TO CHECK rather than risk reporting a false pass" do
          request.remote_addr = "173.245.48.1"
          get :index
          expect(response.body).to eq "173.245.48.1 UNABLE TO CHECK"
        end
      end
    end
  end
end
