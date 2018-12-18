# frozen_string_literal: attribute

require "spec_helper"

describe QueueUpAlertsService do
  context "with no active alerts" do
    it "should log some useful messages" do
      logger = double
      expect(logger).to receive(:info).with("Checking 0 active alerts")
      expect(logger).to receive(:info).with("Splitting mailing for the next 24 hours into batches of size 100 roughly every 1440 minutes")
      expect(logger).to receive(:info).with("Mailing jobs for the next 24 hours queued")
      QueueUpAlertsService.new(logger: logger).call
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
      expect(logger).to receive(:info).with("Splitting mailing for the next 24 hours into batches of size 1 roughly every 720 minutes")
      expect(logger).to receive(:info).with("Mailing jobs for the next 24 hours queued")
      QueueUpAlertsService.new(logger: logger, batch_size: 1).call
    end

    it "should queue up batches" do
      # Silent logger
      logger = double
      allow(logger).to receive(:info)

      delayed1 = double
      delayed2 = double
      service1 = double
      service2 = double
      expect(ProcessAlertsBatchService).to receive(:new).with(alert_ids: [alert1.id]).and_return(service1)
      expect(service1).to receive(:delay).and_return(delayed1)
      expect(delayed1).to receive(:call)
      expect(ProcessAlertsBatchService).to receive(:new).with(alert_ids: [alert2.id]).and_return(service2)
      expect(service2).to receive(:delay).and_return(delayed2)
      expect(delayed2).to receive(:call)
      QueueUpAlertsService.new(logger: logger, batch_size: 1).call
    end
  end
end
