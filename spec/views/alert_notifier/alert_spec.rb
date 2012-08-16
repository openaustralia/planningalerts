require 'spec_helper'

describe "alert_notifier/alert" do
  it "should not use html entities to encode the description" do
    assign(:alert, mock_model(Alert, :address => "Foo Parade",
      :radius_meters => 2000, :confirm_id => "1234"))
    application = mock_model(Application, :address => "Bar Street",
      :description => "Alterations & additions", :council_reference => "007",
      :location => mock("Location", :lat => 1.0, :lng => 2.0))
    assign(:applications, [application])
    assign(:comments, [])
    assign(:georss_url, "blah")
    render
    rendered.should contain("Alterations & additions")      
  end
end