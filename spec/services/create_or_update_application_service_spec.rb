# frozen_string_literal: true

require "spec_helper"

describe CreateOrUpdateApplicationService do
  let(:authority) { create(:authority) }
  let(:application) do
    described_class.call(
      authority: authority,
      council_reference: "123/45",
      attributes: {
        date_scraped: Date.new(2001, 1, 10),
        address: "Some kind of address",
        description: "A really nice change",
        info_url: "http://foo.com",
        date_received: Date.new(2001, 1, 1),
        on_notice_from: Date.new(2002, 1, 1),
        on_notice_to: Date.new(2002, 2, 1),
        lat: 1.0,
        lng: 2.0,
        suburb: "Sydney",
        state: "NSW",
        postcode: "2000"
      }
    )
  end

  it "automaticallies create a version on creating an application" do
    expect(application.versions.count).to eq 1
  end

  it "populates the version with the current information" do
    version = application.versions.first
    expect(version.application).to eq application
    expect(version.previous_version).to be_nil
    expect(version.authority).to eq authority
    expect(version.date_scraped).to eq Date.new(2001, 1, 10)
    expect(version.council_reference).to eq "123/45"
    expect(version.address).to eq "Some kind of address"
    expect(version.description).to eq "A really nice change"
    expect(version.info_url).to eq "http://foo.com"
    expect(version.date_received).to eq Date.new(2001, 1, 1)
    expect(version.on_notice_from).to eq Date.new(2002, 1, 1)
    expect(version.on_notice_to).to eq Date.new(2002, 2, 1)
    expect(version.lat).to eq 1.0
    expect(version.lng).to eq 2.0
    expect(version.suburb).to eq "Sydney"
    expect(version.state).to eq "NSW"
    expect(version.postcode).to eq "2000"
    expect(version.current).to eq true
  end

  it "does not leave an application record around if the version doesn't validate" do
    expect do
      described_class.call(
        authority: authority,
        council_reference: "123/45",
        # This will not be valid
        attributes: {
          description: "A really nice change",
          address: ""
        }
      )
    end.to raise_error ActiveRecord::RecordInvalid
    expect(ApplicationVersion.count).to eq 0
    expect(Application.count).to eq 0
  end

  context "updated application with new data" do
    let(:updated_application) do
      described_class.call(
        authority: application.authority,
        council_reference: application.council_reference,
        attributes: { address: "A better kind of address" }
      )
    end

    it "creates a new version when updating" do
      expect(updated_application.versions.count).to eq 2
    end

    it "has the new value" do
      expect(updated_application.address).to eq "A better kind of address"
    end

    it "has the new value in the latest version" do
      expect(updated_application.versions[0].address).to eq "A better kind of address"
    end

    it "points to the previous version in the latest version" do
      expect(updated_application.versions[0].previous_version).to eq updated_application.versions[1]
    end

    it "has the old value in the previous version" do
      expect(updated_application.versions[1].address).to eq "Some kind of address"
    end

    it "the latest version should now be current" do
      expect(updated_application.versions[0].current).to eq true
    end

    it "the previous version should now be not current" do
      expect(updated_application.versions[1].current).to eq false
    end
  end

  context "updated application where only date_scraped has changed" do
    let(:updated_application) do
      described_class.call(
        authority: application.authority,
        council_reference: application.council_reference,
        attributes: {
          address: "Some kind of address",
          # Note that date_scraped is more recent than the original
          date_scraped: Date.new(2010, 1, 10)
        }
      )
    end

    it "does not create a new version" do
      expect(updated_application.versions.count).to eq 1
    end
  end

  context "updated application with unchanged data once typecast" do
    let(:updated_application) do
      described_class.call(
        authority: application.authority,
        council_reference: application.council_reference,
        attributes: {
          # Once typecast to a date this is the same as before
          date_received: "2001-01-01"
        }
      )
    end

    it "does not create a new version" do
      expect(updated_application.versions.count).to eq 1
    end
  end
end
