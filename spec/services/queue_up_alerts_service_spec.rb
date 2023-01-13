# frozen_string_literal: true

require "spec_helper"

describe QueueUpAlertsService do
  context "with two confirmed alerts" do
    let!(:alert1) { create(:confirmed_alert) }
    let!(:alert2) { create(:confirmed_alert) }

    it "queues up batches" do
      job = class_double(ProcessAlertJob, perform_later: nil)
      allow(ProcessAlertJob).to receive(:set).and_return(job)
      described_class.call

      expect(ProcessAlertJob).to have_received(:set).twice
      expect(job).to have_received(:perform_later).with(alert1.id)
      expect(job).to have_received(:perform_later).with(alert2.id)
    end
  end
end
