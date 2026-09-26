# frozen_string_literal: true

require "spec_helper"

describe "redirects" do
  include Devise::Test::IntegrationHelpers

  describe "applications nearby page" do
    let(:application) { create(:application) }

    it "redirects to the application page in the new design" do
      get "/applications/#{application.id}/nearby?sort=time"
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
