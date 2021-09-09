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

  desc "Export archive of comments to councillors and replies"
  task export_councillor_archive: :environment do
    # Start by getting all the applications that have visible comments to councillors
    application_ids = Comment.where("councillor_id IS NOT NULL").order(created_at: :desc).visible.group(:application_id).pluck(:application_id)
    applications_info = application_ids.map do |id|
      application = Application.find(id)
      comments_info = application.comments.visible.to_councillor.order(created_at: :desc).map do |comment|
        councillor = comment.councillor
        councillor_info = {
          "councillor_id" => councillor.id,
          "name" => councillor.name,
          "image_url" => councillor.image_url,
          "party" => councillor.party
        }
        replies_info = comment.replies.map do |reply|
          {
            "reply_id" => reply.id,
            "text" => reply.text
          }
        end
        {
          "comment_id" => comment.id,
          "text" => comment.text,
          "name" => comment.name,
          "created_at" => comment.created_at.iso8601,
          "councillor" => councillor_info,
          "replies" => replies_info
        }
      end
      url = "https://www.planningalerts.org.au/applications/#{application.id}"
      {
        "application_id" => application.id,
        "planningalerts_url" => url,
        "internet_archive_url" => "https://web.archive.org/web/20210909/#{url}",
        "comments_to_councillors" => comments_info
      }
    end
    result = { "applications" => applications_info }
    puts result.to_yaml
  end

  desc "Submit all URLs with comments to councillors to Internet Archive for archiving"
  task submit_councillors_to_internet_archive: :environment do
    # Start by getting all the applications that have visible comments to councillors
    application_ids = Comment.where("councillor_id IS NOT NULL").order(created_at: :desc).visible.group(:application_id).pluck(:application_id)
    urls = application_ids.map { |id| "https://www.planningalerts.org.au/applications/#{id}" }
    puts "Submitting #{urls.count} URLs to Internet Archive..."
    index = 0
    WaybackArchiver.archive(urls, strategy: :urls) do |result|
      if result.success?
        puts "#{index}: Successfully archived: #{result.archived_url}"
        index += 1
      else
        puts "Error (HTTP #{result.code}) when archiving: #{result.archived_url}"
      end
    end
  end
end
