# frozen_string_literal: true

namespace :planningalerts do
  namespace :applications do
    desc "Import new applications, index them and send emails"
    task import_and_email: %i[import email]

    desc "Import all the applications for the last few days for all the loaded authorities"
    task :import, [:authority_short_name] => :environment do |_t, args|
      authorities = if args[:authority_short_name]
                      a = Authority.find_short_name_encoded(args[:authority_short_name])
                      raise "Couldn't find authority by short name: #{args[:authority_short_name]}" if a.nil?

                      [a]
                    else
                      Authority.active
                    end
      puts "Importing #{authorities.count} authorities"
      authorities.each do |authority|
        info_logger = AuthorityLogger.new(authority.id, Logger.new($stdout))
        ImportApplicationsService.call(authority:, logger: info_logger)
      end
    end

    desc "Send planning alerts"
    task email: :environment do
      QueueUpAlertsService.call(logger: Logger.new($stdout))
    end
  end

  desc "Take a snapshot of planningalerts indexes on elasticsearch and store on S3"
  task elasticsearch_snapshot: :environment do
    ElasticSearchClient&.snapshot&.create_repository(
      repository: "backups",
      body: {
        type: "s3",
        settings: {
          bucket: ENV.fetch("ELASTICSEARCH_SNAPSHOT_S3_BUCKET", nil),
          region: ENV.fetch("ELASTICSEARCH_SNAPSHOT_S3_REGION", nil),
          access_key: ENV.fetch("ELASTICSEARCH_SNAPSHOT_ACCESS_KEY", nil),
          secret_key: ENV.fetch("ELASTICSEARCH_SNAPSHOT_SECRET_KEY", nil),
          compress: true
        }
      }
    )
    ElasticSearchClient&.snapshot&.create(
      repository: "backups",
      snapshot: "pa-api-#{ENV.fetch('STAGE', nil)}-#{Time.zone.now.utc.strftime('%Y.%m.%d')}",
      body: { indices: "pa-api-#{ENV.fetch('STAGE', nil)}-*" }
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

    desc "Strip whitespace from users email"
    task strip_users_email_whitespace: :environment do
      User.where("email like ?", " %").or(User.where("email like ?", "% ")).find_each do |user|
        user.email = user.email.strip
        user.skip_reconfirmation!
        user.save!(validate: false)
      end
    end
  end
end
