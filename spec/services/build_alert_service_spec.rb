# frozen_string_literal: true

require "spec_helper"

describe BuildAlertService do
  describe "#parse" do
    before :each do
      mock_geocoder_valid_address_response
    end

    context "when there is no matching pre-existing Alert" do
      it "returns the original alert" do
        parser_result = BuildAlertService.new(
          address: "24 Bruce Rd, Glenbrook",
          email: "foo@foo.com",
          radius_meters: 1000
        ).parse

        expect(parser_result.email).to eql "foo@foo.com"
        expect(parser_result.radius_meters).to eql 1000
      end

      it "geocodes the alert" do
        parser_result = BuildAlertService.new(
          address: "24 Bruce Rd, Glenbrook",
          email: "foo@foo.com",
          radius_meters: 1000
        ).parse

        expect(parser_result.address).to eq "24 Bruce Rd, Glenbrook, VIC 3885"
        expect(parser_result.geocoded?).to be true
      end
    end

    context "when there is a matching pre-existing unconfirmed Alert" do
      let!(:preexisting_alert) do
        create(
          :unconfirmed_alert,
          address: "24 Bruce Rd, Glenbrook, VIC 3885",
          email: "jenny@example.com",
          created_at: 3.days.ago,
          updated_at: 3.days.ago
        )
      end

      it "resends the confirmation email for the pre-existing alert" do
        allow(ConfirmationMailer).to receive(:confirm).with(preexisting_alert).and_call_original

        BuildAlertService.new(
          email: "jenny@example.com",
          address: "24 Bruce Rd, Glenbrook",
          radius_meters: 1000
        ).parse

        expect(ConfirmationMailer).to have_received(:confirm).with(preexisting_alert)
      end

      it "returns nil" do
        parser_result = BuildAlertService.new(
          email: "jenny@example.com",
          address: "24 Bruce Rd, Glenbrook",
          radius_meters: 1000
        ).parse

        expect(parser_result).to be nil
      end
    end

    context "when there is a matching confirmed alert" do
      let!(:preexisting_alert) do
        create(
          :confirmed_alert,
          address: "24 Bruce Rd, Glenbrook, VIC 3885",
          email: "jenny@example.com",
          created_at: 3.days.ago,
          updated_at: 3.days.ago
        )
      end

      it "returns nil" do
        parser_result = BuildAlertService.new(
          email: "jenny@example.com",
          address: "24 Bruce Rd, Glenbrook",
          radius_meters: 1000
        ).parse

        expect(parser_result).to be nil
      end

      it "sends a helpful email to the alert’s email address" do
        allow(AlertNotifier).to receive(:new_signup_attempt_notice).with(preexisting_alert).and_call_original

        BuildAlertService.new(
          email: "jenny@example.com",
          address: "24 Bruce Rd, Glenbrook",
          radius_meters: 1000
        ).parse

        expect(AlertNotifier).to have_received(:new_signup_attempt_notice).with(preexisting_alert)
      end

      context "but it is unsubscribed" do
        before do
          preexisting_alert.unsubscribe!
        end

        it "returns the new alert" do
          parser_result = BuildAlertService.new(
            email: "jenny@example.com",
            address: "24 Bruce Rd, Glenbrook",
            radius_meters: 1000
          ).parse

          expect(parser_result.email).to eq "jenny@example.com"
        end
      end
    end
  end
end
