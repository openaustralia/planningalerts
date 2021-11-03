# frozen_string_literal: true

require "spec_helper"

describe ProcessAlertAndRecordStatsService do
  context "with two confirmed alerts" do
    let(:alert) { create(:confirmed_alert) }

    before do
      allow(ProcessAlertService).to receive(:call).with(alert: alert).and_return([1, 5, 1])
    end

    it "processes the individual alert" do
      expect(ProcessAlertService).to receive(:call).with(alert: alert).and_return([1, 5, 1])
      allow(Alert).to receive(:find).with(alert.id).and_return(alert)
      described_class.call(alert_id: alert.id)
    end

    it "creates a record of the batch of sent email alerts" do
      allow(Alert).to receive(:find).with(alert.id).and_return(alert)

      described_class.call(alert_id: alert.id)
      expect(EmailBatch.count).to eq 1
      batch = EmailBatch.first
      expect(batch.no_emails).to eq 1
      expect(batch.no_applications).to eq 5
      expect(batch.no_comments).to eq 1
    end

    it "increments the global stats" do
      # Starting point
      Stat.increment_emails_sent(5)
      Stat.increment_applications_sent(10)

      allow(Alert).to receive(:find).with(alert.id).and_return(alert)

      described_class.call(alert_id: alert.id)
      expect(Stat.emails_sent).to eq 6
      expect(Stat.applications_sent).to eq 15
    end
  end
end
