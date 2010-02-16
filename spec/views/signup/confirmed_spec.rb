require 'spec_helper'

describe SignupController do
  describe "distances" do
    it "should be displayed in meters when under 1000m" do
      assigns[:alert] = mock_model(Alert, :area_size_meters => 200, :address => "An address")
      render "signup/confirmed"
      response.should include_text("200m")
    end
    
    it "should be displaying in kilometers when over 1000m" do
      assigns[:alert] = mock_model(Alert, :area_size_meters => 3000, :address => "An address")
      render "signup/confirmed"
      response.should include_text("3km")
    end
  end
end