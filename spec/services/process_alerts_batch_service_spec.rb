# frozen_string_literal: true

require "spec_helper"

describe ProcessAlertsBatchService do
  context "with two confirmed alerts" do
    let(:alert1) { create(:confirmed_alert) }
    let(:alert2) { create(:confirmed_alert) }
    let(:alert3) { create(:confirmed_alert) }

    before(:each) do
      allow(alert1).to receive(:process!).and_return([5, 1, 0])
      allow(alert2).to receive(:process!).and_return([3, 2, 0])
      allow(alert3).to receive(:process!).and_return([0, 0, 0])
    end

    it "should process each individual alert" do
      expect(alert1).to receive(:process!).and_return([5, 1, 0])
      expect(alert2).to receive(:process!).and_return([3, 2, 0])
      expect(alert3).to receive(:process!).and_return([0, 0, 0])
      allow(Alert).to receive(:find).with([alert1.id, alert2.id, alert3.id]).and_return([alert1, alert2, alert3])
      ProcessAlertsBatchService.new(alert_ids: [alert1.id, alert2.id, alert3.id]).call
    end

    it "should tally up the number of things sent and return that" do
      allow(Alert).to receive(:find).with([alert1.id, alert2.id, alert3.id]).and_return([alert1, alert2, alert3])

      expect(ProcessAlertsBatchService.new(alert_ids: [alert1.id, alert2.id, alert3.id]).call).to eq [2, 8, 3]
    end

    it "should create a record of the batch of sent email alerts" do
      allow(Alert).to receive(:find).with([alert1.id, alert2.id, alert3.id]).and_return([alert1, alert2, alert3])

      ProcessAlertsBatchService.new(alert_ids: [alert1.id, alert2.id, alert3.id]).call
      expect(EmailBatch.count).to eq 1
      batch = EmailBatch.first
      expect(batch.no_emails).to eq 2
      expect(batch.no_applications).to eq 8
      expect(batch.no_comments).to eq 3
    end

    it "should increment the global stats" do
      # Starting point
      Stat.emails_sent = 5
      Stat.applications_sent = 10

      allow(Alert).to receive(:find).with([alert1.id, alert2.id, alert3.id]).and_return([alert1, alert2, alert3])

      ProcessAlertsBatchService.new(alert_ids: [alert1.id, alert2.id, alert3.id]).call
      expect(Stat.emails_sent).to eq 7
      expect(Stat.applications_sent).to eq 18
    end
  end
end
