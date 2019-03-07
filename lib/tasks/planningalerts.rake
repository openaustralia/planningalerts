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

  # A response to something bad
  namespace :emergency do
    desc "Applications for an authority shouldn't have duplicate values of council_reference and so this removes duplicates."
    task fix_duplicate_council_references: :environment do
      # First find all duplicates
      duplicates = Application.group(:authority_id).group(:council_reference).count.select { |_k, v| v > 1 }.map { |k, _v| k }
      puts "#{duplicates.count} council references with multiple records"
      duplicates.each do |authority_id, council_reference|
        authority = Authority.find(authority_id)
        puts "Removing duplicates for #{authority.full_name_and_state} - #{council_reference} and redirecting..."
        applications = authority.applications.where(council_reference: council_reference)
        # The first result is the most recently scraped. We want to keep the last result which was the first
        # one scraped
        application_to_keep = applications[-1]
        applications[0..-2].each do |a|
          ActiveRecord::Base.transaction do
            # Set up a redirect from the wrong to the right
            ApplicationRedirect.create!(application_id: a.id, redirect_application_id: application_to_keep.id)
            # Move each comment to the application_to_keep
            a.comments.each do |comment|
              comment.update(application: application_to_keep)
            end
            a.reload
            a.destroy
          end
        end
      end
    end
  end
end
