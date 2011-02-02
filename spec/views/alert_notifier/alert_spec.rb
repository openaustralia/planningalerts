require 'spec_helper'

describe AlertNotifier do
  it "should not use html entities to encode the description" do
    assigns[:alert] = mock_model(Alert, :address => "Foo Parade",
      :radius_meters => 2000, :confirm_id => "1234")
    application = mock_model(Application, :address => "Bar Street",
      :description => "Alterations & additions", :council_reference => "007")
    assigns[:applications] = [application]
    assigns[:georss_url] = "blah"
    render "alert_notifier/alert"
    response.should include_text("Alterations & additions")      
  end
end