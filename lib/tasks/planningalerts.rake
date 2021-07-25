# frozen_string_literal: true

namespace :planningalerts do
  namespace :applications do
    desc "Import new applications, index them and send emails"
    # TODO: Rename the task to use "import"
    # IMPORTANT: Also will need to update the cron job in production to match
    task scrape_and_email: %i[scrape email]

    desc "Import all the applications for the last few days for all the loaded authorities"
    task :scrape, [:authority_short_name] => :environment do |_t, args|
      authorities = args[:authority_short_name] ? [Authority.find_short_name_encoded(args[:authority_short_name])] : Authority.active
      puts "Importing #{authorities.count} authorities"
      authorities.each do |authority|
        info_logger = AuthorityLogger.new(authority.id, Logger.new(STDOUT))
        ImportApplicationsService.call(authority: authority, logger: info_logger)
      end
    end

    desc "Send planning alerts"
    task email: :environment do
      QueueUpAlertsService.call(logger: Logger.new(STDOUT))
    end
  end

  desc "Take a snapshot of planningalerts indexes on elasticsearch and store on S3"
  task elasticsearch_snapshot: :environment do
    ElasticSearchClient&.snapshot&.create_repository(
      repository: "backups",
      body: {
        type: "s3",
        settings: {
          bucket: ENV["ELASTICSEARCH_SNAPSHOT_S3_BUCKET"],
          region: ENV["ELASTICSEARCH_SNAPSHOT_S3_REGION"],
          access_key: ENV["ELASTICSEARCH_SNAPSHOT_ACCESS_KEY"],
          secret_key: ENV["ELASTICSEARCH_SNAPSHOT_SECRET_KEY"],
          compress: true
        }
      }
    )
    ElasticSearchClient&.snapshot&.create(
      repository: "backups",
      snapshot: "pa-api-#{ENV['STAGE']}-#{Time.zone.now.utc.strftime('%Y.%m.%d')}",
      body: { indices: "pa-api-#{ENV['STAGE']}-*" }
    )
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
