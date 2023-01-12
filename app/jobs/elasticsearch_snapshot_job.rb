# typed: strict
# frozen_string_literal: true

class ElasticsearchSnapshotJob < ApplicationJob
  extend T::Sig

  queue_as :default

  sig { void }
  def perform
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
end
