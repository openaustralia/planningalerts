# frozen_string_literal: true

require "spec_helper"

describe QueueUpAlertsService do
  let(:logger) do
    logger = Logger.new($stdout)
    allow(logger).to receive(:info)
    logger
  end

  context "with no active alerts" do
    it "logs some useful messages" do
      described_class.call(logger: logger)

      expect(logger).to have_received(:info).with("Checking 0 active alerts")
      expect(logger).to have_received(:info).with("Splitting mailing for the next 24 hours - checks an alert roughly every 86400 seconds")
      expect(logger).to have_received(:info).with("Mailing jobs for the next 24 hours queued")
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
      described_class.call(logger: logger)

      expect(logger).to have_received(:info).with("Checking 2 active alerts")
      expect(logger).to have_received(:info).with("Splitting mailing for the next 24 hours - checks an alert roughly every 43200 seconds")
      expect(logger).to have_received(:info).with("Mailing jobs for the next 24 hours queued")
    end

    it "queues up batches" do
      job = class_double(ProcessAlertJob, perform_later: nil)
      allow(ProcessAlertJob).to receive(:set).and_return(job)
      described_class.call(logger: logger)

      expect(ProcessAlertJob).to have_received(:set).twice
      expect(job).to have_received(:perform_later).with(alert1.id)
      expect(job).to have_received(:perform_later).with(alert2.id)
    end
  end
end
