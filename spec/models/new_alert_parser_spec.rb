require 'spec_helper'

describe NewAlertParser do
  describe "#parse" do
    around do |example|
      VCR.use_cassette('planningalerts') do
        example.run
      end
    end

    context "when there is no matching pre-existing Alert" do
      it "returns the original alert" do
        alert = build(:alert, id: 7, address: "24 Bruce Rd, Glenbrook", lat: nil, lng: nil)

        parser_result = NewAlertParser.new(alert).parse

        expect(parser_result.id).to eq 7
      end

      it "geocodes the alert" do
        allow(Location).to receive(:geocode).and_return(
          double(full_address: "24 Bruce Rd, Glenbrook NSW 2773", lat: 1, lng: 2, error: nil, all: [])
        )
        alert = build(:alert, id: 7, address: "24 Bruce Rd, Glenbrook", lat: nil, lng: nil)

        parser_result = NewAlertParser.new(alert).parse

        expect(parser_result.address).to eq "24 Bruce Rd, Glenbrook NSW 2773"
      end
    end

    context "when there is a matching pre-existing unconfirmed Alert" do
      let!(:preexisting_alert) do
        create(
          :unconfirmed_alert,
          address: "24 Bruce Rd, Glenbrook NSW 2773",
          email: "jenny@example.com",
          created_at: 3.days.ago,
          updated_at: 3.days.ago
        )
      end

      it "resends the confirmation email for the pre-existing alert" do
        new_alert = build(
          :alert,
          email: "jenny@example.com",
          address: "24 Bruce Rd, Glenbrook",
          lat: nil,
          lng: nil
        )

        # FIXME: This isn't testing that the specific instance has received this message
        expect_any_instance_of(Alert).to receive(:send_confirmation_email)

        NewAlertParser.new(new_alert).parse
      end

      it "returns nil" do
        new_alert = build(
          :alert,
          email: "jenny@example.com",
          address: "24 Bruce Rd, Glenbrook",
          lat: nil,
          lng: nil
        )

        parser_result = NewAlertParser.new(new_alert).parse

        expect(parser_result).to be nil
      end
    end

    context "when there is a matching confirmed alert" do
      let!(:preexisting_alert) do
        create(
          :confirmed_alert,
          address: "24 Bruce Rd, Glenbrook NSW 2773",
          email: "jenny@example.com",
          created_at: 3.days.ago,
          updated_at: 3.days.ago
        )
      end

      it "returns nil" do
        new_alert = build(
          :alert,
          email: "jenny@example.com",
          address: "24 Bruce Rd, Glenbrook",
          lat: nil,
          lng: nil
        )

        parser_result = NewAlertParser.new(new_alert).parse

        expect(parser_result).to be nil
      end

      # it "sends a helpful email to the alert’s email address" do
      #   pending "add this behaviour"
      #   fail
      # end

      context "but it is unsubscribed" do
        before do
          preexisting_alert.unsubscribe!
        end

        it "returns the new alert" do
          new_alert = build(
            :alert,
            id: 9,
            email: "jenny@example.com",
            address: "24 Bruce Rd, Glenbrook",
            lat: nil,
            lng: nil
          )

          parser_result = NewAlertParser.new(new_alert).parse

          expect(parser_result.id).to eq 9
        end
      end
    end
  end
end
