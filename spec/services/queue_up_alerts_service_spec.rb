# frozen_string_literal: attribute

require "spec_helper"

describe QueueUpAlertsService do
  context "with no active alerts" do
    it "should log some useful messages" do
      logger = double
      expect(logger).to receive(:info).with("Checking 0 active alerts")
      expect(logger).to receive(:info).with("Splitting mailing for the next 24 hours - checks an alert roughly every 1440 minutes")
      expect(logger).to receive(:info).with("Mailing jobs for the next 24 hours queued")
      QueueUpAlertsService.call(logger: logger)
    end
  end

  context "with two confirmed alerts" do
    let(:alert1) { create(:confirmed_alert) }
    let(:alert2) { create(:confirmed_alert) }
    before(:each) do
      alert1
      alert2
    end

    it "should log some messages" do
      logger = double
      expect(logger).to receive(:info).with("Checking 2 active alerts")
      expect(logger).to receive(:info).with("Splitting mailing for the next 24 hours - checks an alert roughly every 720 minutes")
      expect(logger).to receive(:info).with("Mailing jobs for the next 24 hours queued")
      QueueUpAlertsService.call(logger: logger)
    end

    it "should queue up batches" do
      # Silent logger
      logger = double
      allow(logger).to receive(:info)

      job = double
      expect(ProcessAlertsBatchJob).to receive(:set).and_return(job).twice
      expect(job).to receive(:perform_later).with([alert1.id])
      expect(job).to receive(:perform_later).with([alert2.id])

      QueueUpAlertsService.call(logger: logger)
    end
  end
end
