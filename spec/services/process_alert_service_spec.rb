# frozen_string_literal: true

require "spec_helper"

describe ProcessAlertService do
  let(:address) { "24 Bruce Road, Glenbrook" }

  context "with an alert with no new comments" do
    let(:alert) { create(:alert, address:) }

    before do
      allow(alert).to receive(:recent_comments).and_return([])
      # Don't know why this isn't cleared out automatically
      ActionMailer::Base.deliveries = []
    end

    context "with a new application nearby" do
      let(:application) do
        create(:application,
               lat: 1.0, lng: 2.0, address: "24 Bruce Road, Glenbrook, NSW",
               suburb: "Glenbrook", state: "NSW", postcode: "2773", no_alerted: 3)
      end

      before do
        allow(alert).to receive(:recent_new_applications).and_return([application])
      end

      it "returns the number of emails, applications and comments sent" do
        expect(described_class.call(alert:)).to eq([1, 1, 0])
      end

      it "sends an email" do
        described_class.call(alert:)
        expect(ActionMailer::Base.deliveries.size).to eq(1)
      end

      it "updates the tally" do
        described_class.call(alert:)
        # Just reload from the database to make sure
        application.reload
        expect(application.no_alerted).to eq(4)
      end

      it "updates the last_sent time" do
        described_class.call(alert:)
        expect((alert.last_sent - Time.zone.now).abs).to be < 1
      end

      it "updates the last_processed time" do
        described_class.call(alert:)
        expect((alert.last_processed - Time.zone.now).abs).to be < 1
      end

      context "with application that was not properly geocoded" do
        let(:application) do
          create(:geocoded_application, lat: 1.0, lng: 2.0, address: "An address that can't be geocoded")
        end

        it "does not cause the application to be re-geocoded" do
          allow(GeocodeService).to receive(:call)
          described_class.call(alert:)
          expect(GeocodeService).not_to have_received(:call)
        end
      end
    end

    context "with no new applications nearby" do
      before do
        allow(alert).to receive(:recent_new_applications).and_return([])
      end

      it "does not send an email" do
        described_class.call(alert:)
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "does not update the last_sent time" do
        described_class.call(alert:)
        expect(alert.last_sent).to be_nil
      end

      it "updates the last_processed time" do
        described_class.call(alert:)
        expect((alert.last_processed - Time.zone.now).abs).to be < 1
      end

      it "returns the number of applications and comments sent" do
        expect(described_class.call(alert:)).to eq([0, 0, 0])
      end
    end
  end
end
