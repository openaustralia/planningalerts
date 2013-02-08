require 'spec_helper'

describe "email_confirmable/confirm/alert" do
  it "should be displayed in meters when under 1000m" do
    assign(:alert, mock_model(Alert, :radius_meters => 200, :address => "An address", :confirm_id => "abcdef")) 
    render
    rendered.should have_content("200 m")
  end
  
  it "should be displaying in kilometers when over 1000m" do
    assign(:alert, mock_model(Alert, :radius_meters => 3000, :address => "An address", :confirm_id => "abcdef"))
    render
    rendered.should have_content("3 km")
  end
end