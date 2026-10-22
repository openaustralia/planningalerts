# frozen_string_literal: true

require "spec_helper"

describe "PlausibleProxy" do
  include WebMock::API

  after { WebMock.reset! }

  it "forwards the analytics script to plausible.io" do
    stub_request(:get, "https://plausible.io/js/script.js")
      .to_return(status: 200, body: "// plausible script")
    get "https://www.planningalerts.org.au/js/script.js"
    expect(response).to have_http_status(:ok)
    expect(response.body).to eq "// plausible script"
  end

  it "forwards analytics events to plausible.io" do
    stub_request(:post, "https://plausible.io/api/event")
      .with(body: '{"n":"pageview"}')
      .to_return(status: 202, body: "ok")
    post "https://www.planningalerts.org.au/api/event",
         params: '{"n":"pageview"}',
         headers: { "CONTENT_TYPE" => "application/json" }
    expect(response).to have_http_status(:accepted)
    expect(response.body).to eq "ok"
  end

  context "when plausible.io is unreachable" do
    before do
      stub_request(:any, %r{\Ahttps://plausible\.io/}).to_timeout
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
