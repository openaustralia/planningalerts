# frozen_string_literal: true

require "spec_helper"

describe QueueUpJobsOverTimeService do
  include ActiveSupport::Testing::TimeHelpers

  it "spreads the jobs evenly over the time given" do
    freeze_time do
      Sidekiq::Testing.fake! do
        ProcessAlertJob.clear

        described_class.call(ProcessAlertJob, 24.hours, [11, 22, 33, 44])

        jobs = ProcessAlertJob.jobs
        expect(jobs.pluck("args")).to eq [[11], [22], [33], [44]]
        # The first is due now, so Sidekiq queues it straight away with no "at"
        expect(jobs.map { |job| job["at"] && (job["at"] - Time.zone.now.to_f).round })
          .to eq [nil, 6.hours.to_i, 12.hours.to_i, 18.hours.to_i]
      end
    end
  end
end
