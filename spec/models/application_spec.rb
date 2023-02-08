# frozen_string_literal: true

require "spec_helper"

describe Application do
  let(:authority) { create(:authority) }

  describe "validation" do
    describe "council_reference" do
      it { expect(build(:application_with_no_version, council_reference: "")).not_to be_valid }

      context "when one application already exists" do
        before do
          create(:geocoded_application, council_reference: "A01", authority:)
        end

        let(:authority2) { create(:authority, full_name: "A second authority") }

        it { expect(build(:application_with_no_version, council_reference: "A01", authority:)).not_to be_valid }
        it { expect(build(:application_with_no_version, council_reference: "A02", authority:)).to be_valid }
        it { expect(build(:application_with_no_version, council_reference: "A01", authority: authority2)).to be_valid }
      end
    end
  end

  describe "on saving" do
    it "geocodes the address" do
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
      allow(GeocodeService).to receive(:call).with("24 Bruce Road, Glenbrook, NSW").and_return(loc)
      a = create(:application, address: "24 Bruce Road, Glenbrook, NSW", council_reference: "r1", date_scraped: Time.zone.now)
      expect(a.lat).to eq(loc.top.lat)
      expect(a.lng).to eq(loc.top.lng)
    end

    it "logs an error if the geocoder can't make sense of the address" do
      allow(GeocodeService).to receive(:call).with("dfjshd").and_return(
        GeocoderResults.new([], "something went wrong")
      )
      logger = instance_double(Logger, error: nil)

      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(ApplicationVersion).to receive(:logger).and_return(logger)
      # rubocop:enable RSpec/AnyInstance
      a = create(:application, address: "dfjshd", council_reference: "r1", date_scraped: Time.zone.now)
      expect(logger).to have_received(:error).with("Couldn't geocode address: dfjshd (something went wrong)")
      expect(a.lat).to be_nil
      expect(a.lng).to be_nil
    end
  end

  # TODO: The main code in the application does not yet reflect this way of doing a query
  describe ".with_first_version" do
    it "does not do too many sql queries" do
      create_list(:geocoded_application, 5)
      allow(ActiveRecord::Base.connection).to receive(:exec_query).and_call_original

      described_class.with_first_version.order("application_versions.date_scraped DESC").includes(:current_version).all.map(&:description)
      expect(ActiveRecord::Base.connection).to have_received(:exec_query).at_most(:twice)
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

    it "is the initial date scraped" do
      date_scraped = application.first_date_scraped
      expect(updated_application.first_date_scraped).to eq date_scraped
      expect(updated_application.current_version.date_scraped).not_to eq date_scraped
    end
  end

  describe "#comment_email_with_fallback" do
    let(:authority) { create(:authority, email: "council@foo.com") }

    context "when application has comment_email set to nil" do
      let(:application) { create(:geocoded_application, authority:) }

      it "returns the email address of the authority" do
        expect(application.comment_email_with_fallback).to eq "council@foo.com"
      end
    end

    context "when application has comment_email set to specialplace@bar.com" do
      let(:application) { create(:geocoded_application, authority:, comment_email: "specialplace@bar.com") }

      it "returns the overridden email address connected to the application" do
        expect(application.comment_email_with_fallback).to eq "specialplace@bar.com"
      end
    end
  end

  describe "#comment_authority_with_fallback" do
    let(:authority) { create(:authority, full_name: "Foo Council") }

    context "when application has comment_authority set to nil" do
      let(:application) { create(:geocoded_application, authority:) }

      it "returns the the full name of the authority" do
        expect(application.comment_authority_with_fallback).to eq "Foo Council"
      end
    end

    context "when application has comment_authority set to Special Council" do
      let(:application) { create(:geocoded_application, authority:, comment_authority: "Special Council") }

      it "returns the overridden name connected to the application" do
        expect(application.comment_authority_with_fallback).to eq "Special Council"
      end
    end
  end
end
