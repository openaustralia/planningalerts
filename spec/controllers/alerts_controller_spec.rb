require 'spec_helper'

describe AlertsController do
  before :each do
    request.env['HTTPS'] = 'on'
  end

  describe "confirming" do
    it "should set the alert to be confirmed" do
      alert = create(:alert)
      Alert.should_receive(:find_by!).with(confirm_id: "1234").and_return(alert)
      alert.should_receive(:confirm!)
      get :confirmed, resource: 'alerts', id: "1234"
    end

    it "should set the alert to be confirmed when on an iPhone" do
      request.stub(:user_agent).and_return('iphone')
      alert = create(:alert)
      Alert.should_receive(:find_by!).with(confirm_id: "1234").and_return(alert)
      alert.should_receive(:confirm!)
      get :confirmed, resource: 'alerts', id: "1234"
      response.should be_success
    end

    it "should return a 404 when the wrong confirm_id is used" do
      expect { get :confirmed, resource: 'alerts', id: "1111" }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "unsubscribing" do
    it "should delete the alert when unsubscribing" do
      alert = mock_model(Alert)
      Alert.should_receive(:find_by_confirm_id).with("1234").and_return(alert)
      alert.should_receive(:update_attribute).with(:unsubscribed, true)
      get :unsubscribe, id: "1234"
    end
    
    # In order to avoid confusion when clicking on unsubscribe link twice -
    it "should allow unsubscribing for non-existent alerts" do
      get :unsubscribe, id: "1111"
      response.should be_success
    end
  end

  describe "area" do
    it "should 404 if the alert can't be found" do
      lambda {
        get :area, id: 'non_existent_id'
      }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
