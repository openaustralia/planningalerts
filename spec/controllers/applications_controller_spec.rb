# frozen_string_literal: true

require "spec_helper"

describe ApplicationsController do
  before :each do
    request.env["HTTPS"] = "on"
  end

  describe "#index" do
    describe "rss feed" do
      before :each do
        allow(GeocoderService).to receive(:geocode).and_return(double(lat: 1.0, lng: 2.0, full_address: "24 Bruce Road, Glenbrook NSW 2773"))
      end

      it "should not provide a link for all applications" do
        get :index
        expect(assigns[:rss]).to be_nil
      end
    end

    describe "error checking on parameters used" do
      it "should not do error checking on the normal html sites" do
        VCR.use_cassette("planningalerts") do
          get :index, params: { address: "24 Bruce Road Glenbrook", radius: 4000, foo: 200, bar: "fiddle" }
        end
        expect(response.code).to eq("200")
      end
    end

    describe "search by authority" do
      it "should give a 404 when an invalid authority_id is used" do
        expect(Authority).to receive(:find_short_name_encoded).with("this_authority_does_not_exist").and_return(nil)
        expect { get :index, params: { authority_id: "this_authority_does_not_exist" } }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "#show" do
    it "should gracefully handle an application without any geocoded information" do
      application = VCR.use_cassette("application_with_no_address") do
        create(
          :application,
          address: "An address that can't be geocoded",
          id: 1
        )
      end

      allow(application).to receive(:location).and_return(nil)
      allow(application).to receive(:find_all_nearest_or_recent).and_return([])

      # TODO: Can this line be removed? It seems to be a duplicate of
      # expectation on final line.
      expect(Application).to receive(:find).with("1").and_return(application)

      get :show, params: { id: 1 }

      expect(assigns[:application]).to eq application
    end

    context "a redirect is set up" do
      let(:redirect) { create(:application_redirect) }
      before(:each) do
        redirect
      end

      it "should redirect to another application" do
        get :show, params: { id: redirect.application_id }
        expect(response).to redirect_to(id: redirect.redirect_application_id)
      end
    end
  end

  describe "#address" do
    it "should set the radius to the supplied parameter" do
      VCR.use_cassette("planningalerts") do
        get :address, params: { address: "24 Bruce Road Glenbrook", radius: 500 }
      end
      expect(assigns[:radius]).to eq 500.0
    end

    it "should set the radius to the default when not supplied" do
      VCR.use_cassette("planningalerts") do
        get :address, params: { address: "24 Bruce Road Glenbrook" }
      end
      expect(assigns[:radius]).to eq 2000.0
    end
  end

  describe "#nearby" do
    context "a redirect is set up" do
      let(:redirect) { create(:application_redirect) }
      before(:each) do
        redirect
      end

      it "should redirect to another application" do
        get :nearby, params: { id: redirect.application_id }
        expect(response).to redirect_to(id: redirect.redirect_application_id)
      end
    end

    context "an application with nothing nearby" do
      let(:application) { create(:geocoded_application) }
      before(:each) do
        application
      end

      it "should redirect if sort isn't set" do
        get :nearby, params: { id: application.id }
        expect(response).to redirect_to(sort: "time")
      end

      it "should render something" do
        get :nearby, params: { id: application.id, sort: "time" }
        expect(response).to be_successful
      end
    end
  end
end
