require 'spec_helper'

describe AlertsController do
  describe "confirming" do
    it "should set the alert to be confirmed" do
      alert = mock_model(Alert)
      Alert.should_receive(:find_by_confirm_id).with("1234").and_return(alert)
      alert.should_receive(:confirmed=).with(true)
      alert.should_receive(:save!)
      get :confirmed, :cid => "1234"
    end
    
    it "should return a 404 when the wrong confirm_id is used" do
      get :confirmed, :cid => "1111"
      response.code.should == "404"
    end
  end
  
  describe "unsubscribing" do
    it "should delete the alert when unsubscribing" do
      alert = mock_model(Alert)
      Alert.should_receive(:find_by_confirm_id).with("1234").and_return(alert)
      alert.should_receive(:delete)
      get :unsubscribe, :cid => "1234"
    end
    
    # In order to avoid confusion when clicking on unsubscribe link twice -
    it "should allow unsubscribing for non-existent alerts" do
      get :unsubscribe, :cid => "1111"
      response.should be_success
    end
  end

  describe "search engine optimisation" do
    it "should provide a sensible title and meta description to make search results useful to people" do
      get :signup
      assigns[:page_title].should == "Email alerts of planning applications near you"
      assigns[:meta_description].should == "A free service which searches Australian planning authority websites and emails you details of applications near you"
    end
  end
end
