require 'spec_helper'

describe "alert_notifier/alert" do
  it "should not use html entities to encode the description" do
    assign(:alert, mock_model(Alert, :address => "Foo Parade",
      :radius_meters => 2000, :confirm_id => "1234"))
    application = mock_model(Application, :address => "Bar Street",
      :description => "Alterations & additions", :council_reference => "007")
    assign(:applications, [application])
    assign(:georss_url, "blah")
    assign(:host, 'dev.planningalerts.org.au')
    render
    rendered.should contain("Alterations & additions")      
  end
end