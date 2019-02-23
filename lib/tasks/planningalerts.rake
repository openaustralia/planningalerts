# frozen_string_literal: true

namespace :planningalerts do
  namespace :applications do
    desc "Import new applications, index them, send emails and generate XML sitemap"
    # TODO: Rename the task to use "import"
    # IMPORTANT: Also will need to update the cron job in production to match
    task scrape_and_email: [:scrape, "ts:index", :email, :sitemap]

    desc "Import all the applications for the last few days for all the loaded authorities"
    task :scrape, [:authority_short_name] => :environment do |_t, args|
      authorities = args[:authority_short_name] ? [Authority.find_short_name_encoded(args[:authority_short_name])] : Authority.active
      puts "Importing #{authorities.count} authorities"
      authorities.each do |authority|
        info_logger = AuthorityLogger.new(authority.id, Logger.new(STDOUT))
        ImportApplicationsService.call(authority: authority, scrape_delay: ENV["SCRAPE_DELAY"].to_i, logger: info_logger)
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

  desc "Migrate api_statistics table from mysql to elasticsearch"
  task migrate_api_statistics: :environment do
    # This is the id of the first record that was also captured live
    # in elasticsearch. So, we only need to go up to that id
    CUTOFF_ID = 95554272
    result = ElasticSearchClient&.search(
      size: 0,
      index: "pa-api-#{ENV['STAGE']}",
      body: {
        aggregations: { max_id: { max: { field: "mysql_id" } } }
      }
    )
    max_id = result["aggregations"]["max_id"]["value"].to_i
    api_statistics = ApiStatistic.where("id > ?", max_id).where("id < ?", CUTOFF_ID)
    progressbar = ProgressBar.create(total: api_statistics.count, format: "%b %c/%C %E")
    # TODO: Change batch size to something sensible
    api_statistics.find_in_batches(batch_size: 1000) do |batch|
      updates = batch.map do |a|
        {
          index: {
            _index: "pa-api-#{ENV['STAGE']}",
            _type: "api",
            _id: a.id,
            data: {
              mysql_id: a.id,
              ip_address: a.ip_address,
              query: a.query,
              user_agent: a.user_agent,
              query_time: a.query_time,
              user: {
                id: a.user&.id,
                email: a.user&.email,
                name: a.user&.name,
                organisation: a.user&.organisation,
                bulk_api: a.user&.bulk_api,
                api_disabled: a.user&.api_disabled
              }
            }
          }
        }
      end
      ElasticSearchClient&.bulk body: updates
      progressbar.progress += batch.size
    end
  end

  desc "Generate XML sitemap"
  task sitemap: :environment do
    GenerateSitemapService.call
  end

  # A response to something bad
  namespace :emergency do
    # TODO: Move comments of destroyed applications to the redirected application
    desc "Applications for an authority shouldn't have duplicate values of council_reference and so this removes duplicates."
    task fix_duplicate_council_references: :environment do
      # First find all duplicates
      duplicates = Application.group(:authority_id).group(:council_reference).count.select { |_k, v| v > 1 }.map { |k, _v| k }
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
            a.destroy
          end
        end
      end
    end
  end
end
