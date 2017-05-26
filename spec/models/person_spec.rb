require 'spec_helper'

RSpec.describe Person, type: :model do
  it "they have an email" do
    expect(Person.new(email: "elzia@example.org").email).to eql "elzia@example.org"
  end

  describe ".subscribed_one_week_ago" do
    before :each do
      Timecop.freeze(Time.utc(2017, 5, 27))

      create(:confirmed_alert, email: "jane@example.org", created_at: Time.utc(2017, 5, 20, 5, 32))
      create(:confirmed_alert, email: "eliza@example.org", created_at: Time.utc(2017, 5, 20, 15, 16))
      create(:confirmed_alert, email: "old_subscribed@example.org", created_at: Time.utc(2017, 5, 20, 11, 02))
      create(:confirmed_alert, email: "old_subscribed@example.org", created_at: Time.utc(2017, 4, 29))
    end

    after :each do
      Timecop.return
    end

    it "returns the people who subscribed one week ago" do
      expect(Person.subscribed_one_week_ago.map(&:email)).to eq [
        "eliza@example.org",
        "jane@example.org"
      ]
    end
  end
end
