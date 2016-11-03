require 'spec_helper'

describe AlertsController do
  before :each do
    request.env['HTTPS'] = 'on'
  end

  describe "confirming" do
    it "should set the alert to be confirmed" do
      alert = create(:alert)
      expect(Alert).to receive(:find_by!).with(confirm_id: "1234").and_return(alert)
      expect(alert).to receive(:confirm!)
      get :confirmed, resource: 'alerts', id: "1234"
    end

    it "should set the alert to be confirmed when on an iPhone" do
      allow(request).to receive(:user_agent).and_return('iphone')
      alert = create(:alert)
      expect(Alert).to receive(:find_by!).with(confirm_id: "1234").and_return(alert)
      expect(alert).to receive(:confirm!)
      get :confirmed, resource: 'alerts', id: "1234"
      expect(response).to be_success
    end

    it "should return a 404 when the wrong confirm_id is used" do
      expect { get :confirmed, resource: 'alerts', id: "1111" }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "unsubscribing" do
    it "should mark the alert as unsubscribed" do
      alert = create :confirmed_alert

      get :unsubscribe, id: alert.confirm_id

      expect(alert.reload).to be_unsubscribed
    end

    # In order to avoid confusion when clicking on unsubscribe link twice -
    it "should allow unsubscribing for non-existent alerts" do
      get :unsubscribe, id: "1111"
      expect(response).to be_success
    end
  end

  describe "area" do
    it "should 404 if the alert can't be found" do
      expect {
        get :area, id: 'non_existent_id'
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
