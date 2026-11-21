# frozen_string_literal: true

require "spec_helper"

describe LogApiCallService do
  # Stand in for Elasticsearch so nothing is written to a real index
  let(:client) { double("client", index: nil) } # rubocop:disable RSpec/VerifiedDoubles

  before { stub_const("ElasticSearchClient", client) }

  it "records an API call, with its key's owner, in that month's index" do
    user = create(:confirmed_user, name: "Alex Example", email: "alex@example.com", organisation: "Example Pty Ltd")
    key = create(:api_key, user:, commercial: true)
    time = Time.utc(2026, 11, 22, 3, 0)

    LogApiCallJob.new.perform(key.value, "192.0.2.1", "/applications.json?postcode=2000",
                              { "postcode" => "2000" }, "ExampleClient/1.0", time.to_f)

    expect(client).to have_received(:index).with(
      index: "pa-api-test-2026.11",
      body: hash_including(
        ip_address: "192.0.2.1",
        query: "/applications.json?postcode=2000",
        params: { "postcode" => "2000" },
        user_agent: "ExampleClient/1.0",
        query_time: time,
        user: hash_including(email: "alex@example.com", organisation: "Example Pty Ltd", api_commercial: true)
      )
    )
  end

  it "skips calls with an unknown key" do
    LogApiCallJob.new.perform("not-a-real-key", "192.0.2.1", "/applications.json", {}, nil, Time.current.to_f)

    expect(client).not_to have_received(:index)
  end
end
