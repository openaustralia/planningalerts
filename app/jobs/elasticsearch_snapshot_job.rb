# typed: strict
# frozen_string_literal: true

class ElasticsearchSnapshotJob
  extend T::Sig
  include Sidekiq::Job

  sig { void }
  def perform
    ElasticSearchClient&.snapshot&.create_repository(
      repository: "backups",
      body: {
        type: "s3",
        settings: {
          bucket: Rails.application.credentials.dig(:elasticsearch, :snapshot, :s3_bucket),
          region: Rails.application.credentials.dig(:elasticsearch, :snapshot, :s3_region),
          access_key: Rails.application.credentials.dig(:elasticsearch, :snapshot, :access_key),
          secret_key: Rails.application.credentials.dig(:elasticsearch, :snapshot, :secret_key),
          compress: true
        }
      }
    )
    ElasticSearchClient&.snapshot&.create(
      repository: "backups",
      snapshot: "pa-api-#{Rails.env}-#{Time.zone.now.utc.strftime('%Y.%m.%d')}",
      body: { indices: "pa-api-#{Rails.env}-*" }
    )
  end
end
