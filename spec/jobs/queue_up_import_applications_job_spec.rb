# frozen_string_literal: true

require "spec_helper"

describe QueueUpImportApplicationsJob do
  it "queues an import for each active authority over the next day" do
    active = create(:authority, morph_name: "planningalerts-scrapers/exampleton")
    create(:authority, morph_name: "planningalerts-scrapers/disabled", disabled: true)
    create(:authority, morph_name: nil)

    Sidekiq::Testing.fake! do
      ImportApplicationsJob.clear

      described_class.new.perform

      expect(ImportApplicationsJob.jobs.pluck("args")).to eq [[active.id]]
    end
  end
end
