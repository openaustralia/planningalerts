# frozen_string_literal: true

require "spec_helper"

describe "redirects" do
  include Devise::Test::IntegrationHelpers

  describe "api redirects" do
    it "does not redirect the normal home page on the normal subdomain" do
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

  describe "applications nearby page" do
    let(:application) { create(:application) }

    it "redirects to the application page in the new design" do
      get nearby_application_path(application, sort: "time")
      expect(response).to redirect_to application_path(application)
    end
  end

  describe "atdis pages" do
    it "redirects to the pdf document in the new design" do
      get atdis_specification_path
      expect(response).to redirect_to "https://github.com/openaustralia/atdis/raw/master/docs/ATDIS-1.0.2%20Application%20Tracking%20Data%20Interchange%20Specification%20(v1.0.2).pdf"
    end

    it "redirects the test page to the get involved page in the new design" do
      get atdis_test_path
      expect(response).to redirect_to get_involved_path
    end
  end
end
