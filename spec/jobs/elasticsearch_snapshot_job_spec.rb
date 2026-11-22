# frozen_string_literal: true

require "spec_helper"

describe ElasticsearchSnapshotJob do
  include ActiveSupport::Testing::TimeHelpers

  # Stand in for Elasticsearch so nothing is sent to S3
  let(:snapshot) { double("snapshot", create_repository: nil, create: nil) } # rubocop:disable RSpec/VerifiedDoubles

  before { stub_const("ElasticSearchClient", double("client", snapshot:)) } # rubocop:disable RSpec/VerifiedDoubles

  it "takes a dated snapshot of the API indices" do
    travel_to Time.zone.parse("2026-11-22 03:00 UTC") do
      described_class.new.perform
    end

    expect(snapshot).to have_received(:create_repository).with(hash_including(repository: "backups"))
    expect(snapshot).to have_received(:create)
      .with(repository: "backups", snapshot: "pa-api-test-2026.11.22", body: { indices: "pa-api-test-*" })
  end
end
