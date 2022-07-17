# frozen_string_literal: true

namespace :planningalerts do
  desc "Test creating a project (beta) and some things in it using the Github API"
  task test: :environment do
    require "graphql/client"
    require "graphql/client/http"
    http = GraphQL::Client::HTTP.new("https://api.github.com/graphql") do
      def headers(context)
        { "Authorization": "bearer #{ENV['GITHUB_PERSONAL_ACCESS_TOKEN']}" }
      end
    end
    schema = GraphQL::Client.load_schema(http)
    client = GraphQL::Client.new(schema: schema, execute: http)

    ViewerLoginQuery = client.parse <<-'GRAPHQL'
      query {
        viewer {
          login
        }
      }
    GRAPHQL
    result = client.query(ViewerLoginQuery)
    p result.data.viewer.login
  end

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
