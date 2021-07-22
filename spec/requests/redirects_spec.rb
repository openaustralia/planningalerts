# frozen_string_literal: true

require "spec_helper"

describe "redirects" do
  describe "api redirects" do
    it "should not redirect the normal home page on the normal subdomain" do
      get "https://www.planningalerts.org.au"
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
end
