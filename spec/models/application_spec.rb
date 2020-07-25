# frozen_string_literal: true

require "spec_helper"

describe Application do
  let(:authority) { create(:authority) }

  describe "validation" do
    describe "council_reference" do
      it { expect(build(:application_with_no_version, council_reference: "")).not_to be_valid }

      context "one application already exists" do
        before :each do
          create(:geocoded_application, council_reference: "A01", authority: authority)
        end
        let(:authority2) { create(:authority, full_name: "A second authority") }

        it { expect(build(:application_with_no_version, council_reference: "A01", authority: authority)).not_to be_valid }
        it { expect(build(:application_with_no_version, council_reference: "A02", authority: authority)).to be_valid }
        it { expect(build(:application_with_no_version, council_reference: "A01", authority: authority2)).to be_valid }
      end
    end
  end

  describe "on saving" do
    it "should geocode the address" do
      loc = GeocoderResults.new(
        [
          GeocodedLocation.new(
            lat: -33.772609,
            lng: 150.624263,
            suburb: "Glenbrook",
            state: "NSW",
            postcode: "2773",
            full_address: "Glenbrook, NSW 2773"
          )
        ],
        nil
      )
      expect(GeocodeService).to receive(:call).with("24 Bruce Road, Glenbrook, NSW").and_return(loc)
      a = create(:application, address: "24 Bruce Road, Glenbrook, NSW", council_reference: "r1", date_scraped: Time.zone.now)
      expect(a.lat).to eq(loc.top.lat)
      expect(a.lng).to eq(loc.top.lng)
    end

    it "should log an error if the geocoder can't make sense of the address" do
      expect(GeocodeService).to receive(:call).with("dfjshd").and_return(
        GeocoderResults.new([], "something went wrong")
      )
      logger = double("Logger")
      expect(logger).to receive(:error).with("Couldn't geocode address: dfjshd (something went wrong)")

      allow_any_instance_of(ApplicationVersion).to receive(:logger).and_return(logger)
      a = create(:application, address: "dfjshd", council_reference: "r1", date_scraped: Time.zone.now)
      expect(a.lat).to be_nil
      expect(a.lng).to be_nil
    end
  end

  describe ".with_current_version" do
    it "should not do too many sql queries" do
      5.times { create(:geocoded_application) }
      expect(ActiveRecord::Base.connection).to receive(:exec_query).at_most(2).times.and_call_original
      Application.with_current_version.order("date_scraped DESC").all.map(&:description)
    end
  end

  describe "#date_scraped" do
    let(:application) { create(:geocoded_application) }

    let(:updated_application) do
      CreateOrUpdateApplicationService.call(
        authority: application.authority,
        council_reference: application.council_reference,
        attributes: {
          description: "An updated description",
          date_scraped: 1.minute.ago
        }
      )
    end

    it "should be the initial date scraped" do
      date_scraped = application.first_date_scraped
      expect(updated_application.first_date_scraped).to eq date_scraped
      expect(updated_application.current_version.date_scraped).to_not eq date_scraped
    end
  end
end
