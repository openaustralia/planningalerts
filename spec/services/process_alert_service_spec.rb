# frozen_string_literal: true

require "spec_helper"

describe ProcessAlertService do
  let(:address) { "24 Bruce Road, Glenbrook" }

  context "an alert with no new comments" do
    let(:alert) { create(:alert, address: address) }
    before :each do
      allow(alert).to receive(:recent_comments).and_return([])
      # Don't know why this isn't cleared out automatically
      ActionMailer::Base.deliveries = []
    end

    context "and a new application nearby" do
      let(:application) do
        create(:application,
               lat: 1.0, lng: 2.0, address: "24 Bruce Road, Glenbrook, NSW",
               suburb: "Glenbrook", state: "NSW", postcode: "2773", no_alerted: 3)
      end

      before :each do
        allow(alert).to receive(:recent_applications).and_return([application])
      end

      it "should return the number of emails, applications, comments and replies sent" do
        expect(ProcessAlertService.call(alert: alert)).to eq([1, 1, 0, 0])
      end

      it "should send an email" do
        ProcessAlertService.call(alert: alert)
        expect(ActionMailer::Base.deliveries.size).to eq(1)
      end

      it "should update the tally" do
        ProcessAlertService.call(alert: alert)
        expect(application.no_alerted).to eq(4)
      end

      it "should update the last_sent time" do
        ProcessAlertService.call(alert: alert)
        expect((alert.last_sent - Time.zone.now).abs).to be < 1
      end

      it "should update the last_processed time" do
        ProcessAlertService.call(alert: alert)
        expect((alert.last_processed - Time.zone.now).abs).to be < 1
      end

      context "that was not properly geocoded" do
        let(:application) do
          VCR.use_cassette("application_with_no_address") do
            create(:application, lat: 1.0, lng: 2.0, address: "An address that can't be geocoded")
          end
        end

        it "should not cause the application to be re-geocoded" do
          expect(Location).to_not receive(:geocode)
          ProcessAlertService.call(alert: alert)
        end
      end
    end

    context "and no new applications nearby" do
      before :each do
        allow(alert).to receive(:recent_applications).and_return([])
      end

      it "should not send an email" do
        ProcessAlertService.call(alert: alert)
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "should not update the last_sent time" do
        ProcessAlertService.call(alert: alert)
        expect(alert.last_sent).to be_nil
      end

      it "should update the last_processed time" do
        ProcessAlertService.call(alert: alert)
        expect((alert.last_processed - Time.zone.now).abs).to be < 1
      end

      it "should return the number of applications, comments and replies sent" do
        expect(ProcessAlertService.call(alert: alert)).to eq([0, 0, 0, 0])
      end
    end

    context "and one new reply nearby" do
      let(:application) do
        create(:application,
               lat: 1.0,
               lng: 2.0,
               address: "24 Bruce Road, Glenbrook, NSW",
               suburb: "Glenbrook",
               state: "NSW",
               postcode: "2773",
               no_alerted: 3)
      end
      let(:reply) do
        create(:reply, comment: create(:comment, application: application),
                       received_at: 1.hour.ago)
      end

      before :each do
        allow(alert).to receive(:new_replies).and_return([reply])
      end

      it "should return the number of applications, comments and replies sent" do
        expect(ProcessAlertService.call(alert: alert)).to eq([1, 0, 0, 1])
      end

      it "should send an email" do
        ProcessAlertService.call(alert: alert)
        expect(ActionMailer::Base.deliveries.size).to eq(1)
      end
    end
  end
end
