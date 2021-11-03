# frozen_string_literal: true

require "spec_helper"

describe QueueUpAlertsService do
  context "with no active alerts" do
    it "logs some useful messages" do
      logger = Logger.new($stdout)
      expect(logger).to receive(:info).with("Checking 0 active alerts")
      expect(logger).to receive(:info).with("Splitting mailing for the next 24 hours - checks an alert roughly every 86400 seconds")
      expect(logger).to receive(:info).with("Mailing jobs for the next 24 hours queued")
      described_class.call(logger: logger)
    end
  end

  context "with two confirmed alerts" do
    let(:alert1) { create(:confirmed_alert) }
    let(:alert2) { create(:confirmed_alert) }

    before do
      alert1
      alert2
    end

    it "logs some messages" do
      logger = Logger.new($stdout)
      expect(logger).to receive(:info).with("Checking 2 active alerts")
      expect(logger).to receive(:info).with("Splitting mailing for the next 24 hours - checks an alert roughly every 43200 seconds")
      expect(logger).to receive(:info).with("Mailing jobs for the next 24 hours queued")
      described_class.call(logger: logger)
    end

    it "queues up batches" do
      # Silent logger
      logger = Logger.new($stdout)
      allow(logger).to receive(:info)

      job = double
      expect(ProcessAlertJob).to receive(:set).and_return(job).twice
      expect(job).to receive(:perform_later).with(alert1.id)
      expect(job).to receive(:perform_later).with(alert2.id)

      described_class.call(logger: logger)
    end
  end
end
