require 'spec_helper'

RSpec.describe AlertSubscriber, type: :model do
  it "they have an email" do
    expect(AlertSubscriber.new(email: "elzia@example.org").email).to eql "elzia@example.org"
  end

  describe ".subscribed_one_week_ago" do
    before :each do
      Timecop.freeze(Time.utc(2017, 5, 27))
    end

    after :each do
      Timecop.return
    end

    context "when nobody first signed up a week ago" do
      before do
        create(:confirmed_alert, email: "old_subscribed@example.org", created_at: Time.utc(2017, 5, 20, 11, 02))
        create(:confirmed_alert, email: "old_subscribed@example.org", created_at: Time.utc(2017, 4, 29))
      end

      it { expect(AlertSubscriber.subscribed_one_week_ago).to be_empty }
    end

    context "when there are people who first signed up a week ago" do
      let!(:alert_one) { create(:confirmed_alert, email: "jane@example.org", created_at: Time.utc(2017, 5, 20, 5, 32)) }
      let!(:alert_two) { create(:confirmed_alert, email: "eliza@example.org", created_at: Time.utc(2017, 5, 20, 15, 16)) }

      it "returns them" do
        expect(AlertSubscriber.subscribed_one_week_ago.map(&:email)).to eq [
          "eliza@example.org",
          "jane@example.org"
        ]
      end

      context "and people who were already signed up added new alerts that day" do
        before do
          create(:confirmed_alert, email: "old_subscribed@example.org", created_at: Time.utc(2017, 5, 20, 11, 02))
          create(:confirmed_alert, email: "old_subscribed@example.org", created_at: Time.utc(2017, 4, 29))
        end

        it "only includes the people who first signed that day" do
          expect(AlertSubscriber.subscribed_one_week_ago.map(&:email)).to eq [
            "eliza@example.org",
            "jane@example.org"
          ]
        end
      end

      context "but they've since unsubscribed all there alerts" do
        before do
          alert_one.unsubscribe!
          alert_two.unsubscribe!
        end

        it { expect(AlertSubscriber.subscribed_one_week_ago).to be_empty }
      end
    end
  end
end
