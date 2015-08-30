require 'spec_helper'

describe ApplicationHelper do

  it "should convert a distance in metres to simple concise text" do
    helper.meters_in_words(2000).should == "2 km"
    helper.meters_in_words(500).should == "500 m"
  end
  
  it "should round distances in km to the nearest 100m" do
    helper.meters_in_words(2345).should == "2.3 km"
  end
  
  it "should round distances in metres to nearest 10m" do
    helper.meters_in_words(923.45).should == "920 m"
  end
  
  it "should round distances less than 100 metres to nearest metre" do
    helper.meters_in_words(84.23).should == "84 m"
  end
  
  it "should round to two significant figures" do
    helper.significant_figure(0.164, 2).should == 0.16
    helper.significant_figure(1.64, 2).should == 1.6
    helper.significant_figure(16.4, 2).should == 16
    helper.significant_figure(164, 2).should == 160
    helper.significant_figure(1640, 2).should == 1600
  end

  it "should round to one significant figure" do
    helper.significant_figure(0.164, 1).should == 0.2
    helper.significant_figure(1.64, 1).should == 2
    helper.significant_figure(16.4, 1).should == 20
    helper.significant_figure(164, 1).should == 200
    helper.significant_figure(1640, 1).should == 2000
  end
  
  it "should round zero without freaking out" do
    helper.significant_figure(0, 1).should == 0
  end
  
  it "should round negative numbers" do
    helper.significant_figure(-2.34, 2).should == -2.3
  end

  describe "#analytics_params" do
    before(:each) { @alert = create(:alert) }
    base_params = { utm_source: "alert", utm_medium: "email" }

    context "for a trial subscriber" do
      before :each do
        allow(@alert).to receive(:trial_subscription?).and_return true
        allow(@alert).to receive(:expired_subscription?).and_return false
      end

      params_for_trial_subscribers = base_params.merge(utm_campaign: "subscribe-from-trial")

      context "without utm_content" do
        it {
          expect(helper.analytics_params(alert: @alert))
            .to eq params_for_trial_subscribers
        }
      end

      context "with utm_content" do
        it {
          expect(helper.analytics_params(alert: @alert, utm_content: "wiz"))
            .to eq params_for_trial_subscribers.merge(utm_content: "wiz")
        }
      end
    end

    context "for someone with an expired subscription" do
      before :each do
        allow(@alert).to receive(:trial_subscription?).and_return false
        allow(@alert).to receive(:expired_subscription?).and_return true
      end
      params_for_expired_subscriber = base_params.merge(utm_campaign: "subscribe-from-expired")

      context "without utm_content" do
        it {
          expect(helper.analytics_params(alert: @alert))
            .to eq params_for_expired_subscriber
        }
      end

      context "with utm_content" do
        it {
          expect(helper.analytics_params(alert: @alert, utm_content: "wiz"))
            .to eq params_for_expired_subscriber.merge(utm_content: "wiz")
        }
      end
    end
  end
end
