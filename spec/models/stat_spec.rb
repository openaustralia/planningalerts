require 'spec_helper'

describe Stat do
  it "should read in the number of applications that have gone out in emails" do
    Stat.delete_all
    Stat.create!(key: "applications_sent", value: 14)

    expect(Stat.applications_sent).to eq(14)
  end

  it "should read in the number of emails that have been sent" do
    Stat.delete_all
    Stat.create!(key: "emails_sent", value: 2)

    expect(Stat.emails_sent).to eq(2)
  end

  it "should return 0 when a key is missing and create the key" do
    Stat.delete_all
    # Stat.logger.should_receive(:error).with("Could not find key applications_sent for Stat lookup")
    expect(Stat.applications_sent).to eq(0)
    expect(Stat.find_by(key: "applications_sent").value).to eq(0)
  end
end
