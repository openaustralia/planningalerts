require 'spec_helper'

describe "redirects" do
  describe "api redirects" do
    it "should not redirect the normal home page on the normal subdomain" do
      VCR.use_cassette('planningalerts') do
        get "http://www.planningalerts.org.au"
      end
      response.should_not be_redirect
    end

    describe "requests on the api subdomain" do
      it "to the home page should redirect" do
        get "http://api.planningalerts.org.au"
        response.should redirect_to "http://www.planningalerts.org.au/"
      end

      it "to the applications index page for html should redirect" do
        get "http://api.planningalerts.org.au/applications?foo=bar"
        response.should redirect_to "http://www.planningalerts.org.au/applications"
      end

      it "to the applications index page for js should not redirect" do
        get "http://api.planningalerts.org.au/applications.js"
        response.should_not be_redirect
      end      
    end
  end
end
