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

    describe "hidden applications" do
      it "does not include hidden applications" do
        application = create(:geocoded_application)
        hidden_application = create(:geocoded_application, :hidden)

        get :index

        expect(assigns[:applications]).to include(application)
        expect(assigns[:applications]).not_to include(hidden_application)
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

      allow(application).to receive_messages(location: nil, find_all_nearest_or_recent: [])

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

    context "when the application is hidden" do
      let!(:application) { create(:geocoded_application, :hidden, id: 1) }

      it "returns 403 forbidden and renders the hidden page for anonymous users" do
        get :show, params: { id: application.id }

        expect(response).to have_http_status(:forbidden)
        expect(response).to render_template("hidden")
      end

      it "returns 403 forbidden for signed in users that are not admins" do
        sign_in create(:confirmed_user)

        get :show, params: { id: application.id }

        expect(response).to have_http_status(:forbidden)
        expect(response).to render_template("hidden")
      end

      it "returns 200 and renders the normal page for admins" do
        admin = create(:confirmed_user)
        admin.add_role(:admin)
        sign_in admin

        get :show, params: { id: application.id }

        expect(response).to have_http_status(:ok)
        expect(response).to render_template("show")
      end
    end
  end

  describe "#external" do
    context "when the application is hidden" do
      let!(:application) { create(:geocoded_application, :hidden, id: 1) }

      it "returns 403 forbidden and renders the hidden page for anonymous users" do
        get :external, params: { id: application.id }

        expect(response).to have_http_status(:forbidden)
        expect(response).to render_template("hidden")
      end

      it "returns 403 forbidden for signed in users that are not admins" do
        sign_in create(:confirmed_user)

        get :external, params: { id: application.id }

        expect(response).to have_http_status(:forbidden)
        expect(response).to render_template("hidden")
      end

      it "returns 200 and renders the normal page for admins" do
        admin = create(:confirmed_user)
        admin.add_role(:admin)
        sign_in admin

        get :external, params: { id: application.id }

        expect(response).to have_http_status(:ok)
        expect(response).to render_template("external")
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

    context "with applications near the searched address" do
      let(:geo_factory) { RGeo::Geographic.spherical_factory(srid: 4326) }
      let!(:application) do
        create(:geocoded_application, lat: -33.772607, lng: 150.624245, lonlat: geo_factory.point(150.624245, -33.772607))
      end
      let!(:hidden_application) do
        create(:geocoded_application, :hidden, lat: -33.772607, lng: 150.624245, lonlat: geo_factory.point(150.624245, -33.772607))
      end

      before { mock_geocoder_valid_address_response }

      it "does not include hidden applications" do
        get :address, params: { q: "24 Bruce Road Glenbrook" }

        expect(assigns[:applications]).to include(application)
        expect(assigns[:applications]).not_to include(hidden_application)
      end
    end
  end
end
