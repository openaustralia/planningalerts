# frozen_string_literal: true

require "spec_helper"

describe ProcessAlertJob do
  it "emails the alert's owner about a new application nearby" do
    alert = create(:alert, user: create(:confirmed_user))
    create(:geocoded_application, lat: alert.lat, lng: alert.lng, lonlat: alert.lonlat,
                                  address: "12 Example Street, Marrickville NSW 2204",
                                  description: "Build a granny flat")
    described_class.new.perform(alert.id)

    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(ActionMailer::Base.deliveries.first.html_part.body.to_s).to include("Build a granny flat")
    expect(EmailBatch.count).to eq 1
  end

  it "does nothing for an alert that has since been deleted" do
    expect { described_class.new.perform(0) }.not_to raise_error
    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
