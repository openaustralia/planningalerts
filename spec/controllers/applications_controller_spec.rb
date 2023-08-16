# frozen_string_literal: true

require "spec_helper"

describe ApplicationsController do
  before do
    request.env["HTTPS"] = "on"
  end

  describe "#index" do
    describe "error checking on parameters used" do
      it "does not do error checking on the normal html sites" do
        get :index, params: { address: "24 Bruce Road Glenbrook", radius: 4000, foo: 200, bar: "fiddle" }
        expect(response).to have_http_status(:ok)
      end
    end

    describe "search by authority" do
      it "gives a 404 when an invalid authority_id is used" do
        allow(Authority).to receive(:find_short_name_encoded).with("this_authority_does_not_exist").and_return(nil)
        expect { get :index, params: { authority_id: "this_authority_does_not_exist" } }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "#show" do
    it "gracefullies handle an application without any geocoded information" do
      address = "An address that can't be geocoded"
      allow(GeocodeService).to receive(:call).with(address).and_return(GeocoderResults.new([], "Couldn't understand address"))
      application = create(
        :application,
        address:,
        id: 1
      )

      allow(application).to receive(:location).and_return(nil)
      allow(application).to receive(:find_all_nearest_or_recent).and_return([])

      # TODO: Can this line be removed? It seems to be a duplicate of
      # expectation on final line.
      allow(Application).to receive(:find).with("1").and_return(application)

      get :show, params: { id: 1 }

      expect(assigns[:application]).to eq application
    end

    context "when a redirect is set up" do
      let(:redirect) { create(:application_redirect) }

      before do
        redirect
      end

      it "redirects to another application" do
        get :show, params: { id: redirect.application_id }
        expect(response).to redirect_to(id: redirect.redirect_application_id)
      end
    end
  end

  describe "#address" do
    before { allow(GoogleGeocodeService).to receive(:call).and_return(GeocoderResults.new([], nil)) }

    it "sets the radius to the supplied parameter" do
      get :address, params: { q: "24 Bruce Road Glenbrook", radius: 500 }
      expect(assigns[:radius]).to eq 500.0
    end

    it "sets the radius to the default when not supplied" do
      get :address, params: { q: "24 Bruce Road Glenbrook" }
      expect(assigns[:radius]).to eq 2000.0
    end
  end

  describe "#nearby" do
    context "when a redirect is set up" do
      let(:redirect) { create(:application_redirect) }

      before do
        redirect
      end

      it "redirects to another application" do
        get :nearby, params: { id: redirect.application_id }
        expect(response).to redirect_to(id: redirect.redirect_application_id)
      end
    end

    context "when an application with nothing nearby" do
      let(:application) { create(:geocoded_application) }

      before do
        application
      end

      it "redirects if sort isn't set" do
        get :nearby, params: { id: application.id }
        expect(response).to redirect_to(sort: "time")
      end

      it "renders something" do
        get :nearby, params: { id: application.id, sort: "time" }
        expect(response).to be_successful
      end
    end
  end
end
