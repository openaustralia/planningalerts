# frozen_string_literal: true

require "spec_helper"

describe "PlausibleProxy" do
  context "when plausible.io is unreachable" do
    before do
      # rack-proxy opens the connection to plausible.io lazily via
      # Net::HTTP#start, using its own "hacked" net/http internals that
      # WebMock can't intercept. So we have to stub at the object level.
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Net::HTTP).to receive(:start).and_raise(Net::OpenTimeout)
      # rubocop:enable RSpec/AnyInstance
    end

    it "returns a 502 rather than raising when proxying analytics events" do
      post "https://www.planningalerts.org.au/api/event"
      expect(response).to have_http_status(:bad_gateway)
    end

    it "returns a 502 rather than raising when proxying the analytics script" do
      get "https://www.planningalerts.org.au/js/script.js"
      expect(response).to have_http_status(:bad_gateway)
    end
  end
end
