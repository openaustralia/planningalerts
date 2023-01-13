# frozen_string_literal: true

namespace :planningalerts do
  namespace :applications do
    desc "Import new applications, index them and send emails"
    task import_and_email: %i[import email]

    desc "Import all the applications for the last few days for all the loaded authorities"
    task import: :environment do
      QueueUpJobsOverTimeService.call(ImportApplicationsJob, 24.hours, Authority.active.all.to_a)
    end

    desc "Send planning alerts"
    task email: :environment do
      QueueUpJobsOverTimeService.call(ProcessAlertJob, 24.hours, Alert.active.pluck(:id).shuffle)
    end
  end

  desc "Generate XML sitemap"
  task sitemap: :environment do
    GenerateSitemapService.call
  end

  namespace :emergency do
    desc "Regenerates all the counter caches in case they got out of synch"
    task fixup_counter_caches: :environment do
      Comment.counter_culture_fix_counts
    end
  end
end
