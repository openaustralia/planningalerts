# frozen_string_literal: true

namespace :planningalerts do
  namespace :applications do
    desc "Queue up importing of new applications and sending of emails"
    task import_and_email: :environment do
      QueueUpImportingAndSendingJob.perform_later
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
