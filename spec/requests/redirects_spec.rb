# frozen_string_literal: true

require "spec_helper"

describe "redirects" do
  describe "api redirects" do
    it "should not redirect the normal home page on the normal subdomain" do
      VCR.use_cassette("planningalerts") do
        get "https://www.planningalerts.org.au"
      end
      expect(response).not_to be_redirect
    end

    describe "requests on the api subdomain" do
      it "to the home page should redirect" do
        get "http://api.planningalerts.org.au"
        expect(response).to redirect_to "http://www.planningalerts.org.au/"
      end

      it "to the applications index page for html should redirect" do
        get "http://api.planningalerts.org.au/applications?foo=bar"
        expect(response).to redirect_to "http://www.planningalerts.org.au/applications"
      end

      it "to the applications index page for js should not redirect" do
        get "http://api.planningalerts.org.au/applications.js"
        expect(response).not_to be_redirect
      end
    end
  end

  describe "ssl redirects" do
    context "in the production environment" do
      before do
        allow(Rails.env).to receive(:production?).and_return true
      end

      it "should redirect to ssl" do
        get "http://www.planningalerts.org.au/applications"
        expect(response).to redirect_to "https://www.planningalerts.org.au/applications"
      end

      it "should redirect the api howto page" do
        get "http://www.planningalerts.org.au/api/howto"
        expect(response).to redirect_to "https://www.planningalerts.org.au/api/howto"
      end
    end
  end
end
