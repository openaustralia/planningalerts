# frozen_string_literal: true

require "spec_helper"

describe WhatismyipController do
  describe "GET #index" do
    context "when the provide_whatismyip feature flag is off" do
      before { get :index }

      it "is not found" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the provide_whatismyip feature flag is on" do
      before { Flipper.enable(:provide_whatismyip) }

      it "returns the remote IP" do
        request.remote_addr = "1.2.3.4"
        get :index
        expect(response.body).to eq "1.2.3.4"
      end

      it "returns an IPv6 remote IP" do
        request.remote_addr = "2001:db8::1"
        get :index
        expect(response.body).to eq "2001:db8::1"
      end
    end
  end
end
