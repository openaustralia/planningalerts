# frozen_string_literal: true

require "spec_helper"

# Rack::Attack is off in specs (see spec/spec_helper.rb), so switch it on here
# with a store that starts empty for each example
describe "API daily limit" do
  around do |example|
    store = Rack::Attack.cache.store
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.enabled = true
    example.run
  ensure
    Rack::Attack.enabled = false
    Rack::Attack.cache.store = store
  end

  before do
    allow(LogApiCallService).to receive(:call)
    host! "api.planningalerts.org.au"
  end

  def call_api(key)
    get "/authorities.json", params: { key: key.value }
  end

  it "stops a key once it reaches its own daily limit" do
    key = create(:api_key, daily_limit: 2)

    2.times do
      call_api(key)
      expect(response).to have_http_status(:ok)
    end
    call_api(key)

    expect(response).to have_http_status(:too_many_requests)
    expect(response.body).to eq "Retry later\n"
  end

  it "counts each key separately" do
    busy = create(:api_key, daily_limit: 1)
    other = create(:api_key, daily_limit: 1)
    call_api(busy)

    call_api(other)

    expect(response).to have_http_status(:ok)
  end
end
