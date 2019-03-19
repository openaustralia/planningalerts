# frozen_string_literal: true

namespace :planningalerts do
  namespace :applications do
    desc "Import new applications, index them, send emails and generate XML sitemap"
    # TODO: Rename the task to use "import"
    # IMPORTANT: Also will need to update the cron job in production to match
    task scrape_and_email: %i[scrape email sitemap elasticsearch_snapshot]

    desc "Import all the applications for the last few days for all the loaded authorities"
    task :scrape, [:authority_short_name] => :environment do |_t, args|
      authorities = args[:authority_short_name] ? [Authority.find_short_name_encoded(args[:authority_short_name])] : Authority.active
      puts "Importing #{authorities.count} authorities"
      authorities.each do |authority|
        info_logger = AuthorityLogger.new(authority.id, Logger.new(STDOUT))
        ImportApplicationsService.call(authority: authority, scrape_delay: ENV["SCRAPE_DELAY"].to_i, logger: info_logger, morph_api_key: ENV["MORPH_API_KEY"])
      end
    end

    desc "Send planning alerts"
    task email: :environment do
      QueueUpAlertsService.call(logger: Logger.new(STDOUT))
    end

    desc "Reset `last_sent` on all alerts to nil and then send emails"
    task reset_last_sent_and_email: %i[reset_last_sent email]

    desc "Set last_sent to nil on all alerts"
    task reset_last_sent: :environment do
      Alert.all.each { |alert| alert.update(last_sent: nil) }
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

  desc "Regenerates all the counter caches in case they got out of synch"
  task fixup_counter_caches: :environment do
    Comment.counter_culture_fix_counts
  end
end
