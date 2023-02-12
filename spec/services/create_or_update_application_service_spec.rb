# frozen_string_literal: true

require "spec_helper"

describe CreateOrUpdateApplicationService do
  let(:authority) { create(:authority) }
  let(:application) do
    described_class.call(
      authority:,
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

  it "sets the first_date_scraped on the application" do
    expect(application.attributes["first_date_scraped"]).to eq Date.new(2001, 1, 10)
  end

  it "automaticallies create a version on creating an application" do
    expect(application.versions.count).to eq 1
  end

  it "also sets the information on the original application" do
    a = application.attributes
    expect(a["date_scraped"]).to eq Date.new(2001, 1, 10)
    expect(a["address"]).to eq "Some kind of address"
    expect(a["description"]).to eq "A really nice change"
    expect(a["info_url"]).to eq "http://foo.com"
    expect(a["date_received"]).to eq Date.new(2001, 1, 1)
    expect(a["on_notice_from"]).to eq Date.new(2002, 1, 1)
    expect(a["on_notice_to"]).to eq Date.new(2002, 2, 1)
    expect(a["lat"]).to eq 1.0
    expect(a["lng"]).to eq 2.0
    expect(a["suburb"]).to eq "Sydney"
    expect(a["state"]).to eq "NSW"
    expect(a["postcode"]).to eq "2000"
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
    expect(version.current).to be true
  end

  it "does not leave an application record around if the version doesn't validate" do
    expect do
      described_class.call(
        authority:,
        council_reference: "123/45",
        # This will not be valid
        attributes: {
          description: "A really nice change",
          address: "",
          lat: 1.0,
          lng: 2.0,
          suburb: "Sydney",
          state: "NSW",
          postcode: "2000"
        }
      )
    end.to raise_error ActiveRecord::RecordInvalid
    expect(ApplicationVersion.count).to eq 0
    expect(Application.count).to eq 0
  end

  context "with updated application with new data" do
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

    it "also updates the field on the main table" do
      a = updated_application.attributes
      expect(a["address"]).to eq "A better kind of address"
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
      expect(updated_application.versions[0].current).to be true
    end

    it "the previous version should now be not current" do
      expect(updated_application.versions[1].current).to be false
    end
  end

  context "with updated application where only date_scraped has changed" do
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

  context "with updated application with unchanged data once typecast" do
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

  context "with an application with no lat and lng when it's created" do
    let(:application) do
      described_class.call(
        authority:,
        council_reference: "123/45",
        attributes: {
          date_scraped: Date.new(2001, 1, 10),
          address: "24 Bruce Road, Glenbrook, NSW",
          description: "A really nice change",
          info_url: "http://foo.com",
          date_received: Date.new(2001, 1, 1),
          on_notice_from: Date.new(2002, 1, 1),
          on_notice_to: Date.new(2002, 2, 1)
        }
      )
    end

    let(:location) do
      GeocodedLocation.new(
        lat: -33.772609,
        lng: 150.624263,
        suburb: "Glenbrook",
        state: "NSW",
        postcode: "2773",
        full_address: "Glenbrook, NSW 2773"
      )
    end

    it "geocodes the address" do
      allow(GeocodeService).to receive(:call).with("24 Bruce Road, Glenbrook, NSW").and_return(GeocoderResults.new([location], nil))

      expect(application.lat).to eq location.lat
      expect(application.lng).to eq location.lng
      expect(application.suburb).to eq location.suburb
      expect(application.state).to eq location.state
      expect(application.postcode).to eq location.postcode
    end

    it "logs an error if the geocoder can't make sense of the address" do
      allow(GeocodeService).to receive(:call).with("24 Bruce Road, Glenbrook, NSW").and_return(
        GeocoderResults.new([], "something went wrong")
      )
      logger = instance_double(Logger, error: nil)

      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(ApplicationVersion).to receive(:logger).and_return(logger)
      # rubocop:enable RSpec/AnyInstance
      expect(application.lat).to be_nil
      expect(application.lng).to be_nil
      expect(logger).to have_received(:error).with("Couldn't geocode address: 24 Bruce Road, Glenbrook, NSW (something went wrong)")
    end
  end
end
