require 'spec_helper'

describe AlertsController do
  describe "distances" do
    it "should be displayed in meters when under 1000m" do
      assigns[:alert] = mock_model(Alert, :area_size_meters => 200, :address => "An address", :confirm_id => "abcdef")
      render "alerts/confirmed"
      response.should include_text("200 m")
    end
    
    it "should be displaying in kilometers when over 1000m" do
      assigns[:alert] = mock_model(Alert, :area_size_meters => 3000, :address => "An address", :confirm_id => "abcdef")
      render "alerts/confirmed"
      response.should include_text("3 km")
    end
  end
end