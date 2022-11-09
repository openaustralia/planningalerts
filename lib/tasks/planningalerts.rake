# frozen_string_literal: true

namespace :planningalerts do
  namespace :applications do
    desc "Import new applications, index them and send emails"
    task import_and_email: %i[import email]

    desc "Import all the applications for the last few days for all the loaded authorities"
    task :import, [:authority_short_name] => :environment do |_t, args|
      authorities = args[:authority_short_name] ? [Authority.find_short_name_encoded(args[:authority_short_name])] : Authority.active
      puts "Importing #{authorities.count} authorities"
      authorities.each do |authority|
        info_logger = AuthorityLogger.new(authority.id, Logger.new($stdout))
        ImportApplicationsService.call(authority: authority, logger: info_logger)
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
  end

  namespace :data_migration do
    desc "Connect alerts to users"
    task connect_alerts_to_users: :environment do
      alerts = Alert.where(user: nil)
      progressbar = ProgressBar.create(total: alerts.count, format: "%t %W %E")

      alerts.find_each do |alert|
        # Find an already connected user
        user = User.find_by(email: alert.email)
        if user.nil?
          # TODO: We don't want api keys for this new user!
          # from_alert_or_comment says that this user was created "from" an alert rather than a user
          # registering an account in the "normal" way
          user = User.new(email: alert.email, from_alert_or_comment: true)
          # Otherwise it would send out a confirmation email on saving the record
          user.skip_confirmation_notification!
          # Disable validation so we can save with an empty password
          user.save!(validate: false)
        end
        # Confirm the user if the alert is already confirmed
        user.confirm if !user.confirmed? && alert.confirmed?

        alert.update!(user: user)
        progressbar.increment
      end
    end

    desc "Connect comments to users"
    task connect_comments_to_users: :environment do
      comments = Comment.where(user: nil)
      progressbar = ProgressBar.create(total: comments.count, format: "%t %W %E")

      comments.find_each do |comment|
        # Find an already connected user
        user = User.find_by(email: comment.email)
        if user.nil?
          # from_alert_or_comment says that this user was created "from" an alert rather than a user
          # registering an account in the "normal" way
          user = User.new(email: comment.email, from_alert_or_comment: true)
          # Otherwise it would send out a confirmation email on saving the record
          user.skip_confirmation_notification!
          # Disable validation so we can save with an empty password
          user.save!(validate: false)
        end
        # Confirm the user if the comment is already confirmed
        user.confirm if !user.confirmed? && comment.confirmed?

        comment.update!(user: user)
        progressbar.increment
      end
    end

    # This is necessary as a pre-step to adding unique validation on the alerts model for the address field
    # TODO: Remove this once that's all up and running
    desc "Remove duplicate alerts"
    task remove_duplicate_alerts: :environment do
      Alert.where(unsubscribed: false).group(:user_id, :address).count.each do |v, c|
        # Only consider cases with duplicates
        next unless c > 1

        alerts = Alert.where(user_id: v.first, address: v.second)
        # Now find the alert we want to keep
        keep = alerts.where(confirmed: true).order(created_at: :desc).first ||
               alerts.order(created_at: :desc).first
        alerts.where.not(id: keep.id).destroy_all
      end
    end
  end
end
