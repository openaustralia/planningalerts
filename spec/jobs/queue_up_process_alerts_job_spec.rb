# frozen_string_literal: true

require "spec_helper"

describe QueueUpProcessAlertsJob do
  it "queues a job for each active alert over the next day" do
    active = create_list(:alert, 2)
    create(:unsubscribed_alert)

    Sidekiq::Testing.fake! do
      ProcessAlertJob.clear

      described_class.new.perform

      expect(ProcessAlertJob.jobs.pluck("args")).to match_array(active.map { |alert| [alert.id] })
    end
  end
end
