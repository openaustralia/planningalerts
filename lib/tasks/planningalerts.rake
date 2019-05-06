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

    desc "Remove versions of applications where only the date_scraped has changed"
    task remove_duplicate_application_versions: :environment do
      # First find applications with more than one version
      ids = ApplicationVersion.group(:application_id).count.select { |_k, v| v > 1 }.keys
      ids.each do |id|
        application = Application.find(id)
        puts "Checking application #{id} and fixing if necessary..."
        # Go through each version and check if anything has changed
        application.versions.each do |version|
          current_attributes = version.attributes
          previous_attributes = if version.previous_version
                                  version.previous_version.attributes
                                else
                                  {}
                                end
          changed_attributes = []
          current_attributes.each do |k, v|
            changed_attributes << k if v != previous_attributes[k]
          end
          changed_attributes = changed_attributes.without(
            "id", "previous_version_id", "current", "date_scraped", "created_at", "updated_at"
          )

          next unless changed_attributes.empty?

          # Doing this to ensure that current gets reloaded
          version.reload
          ApplicationVersion.transaction do
            version.destroy!
            version.previous_version.update!(current: true) if version.current
          end
        end
      end
    end
  end
end
