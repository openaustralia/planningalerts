# frozen_string_literal: true

require "spec_helper"

# Separate from import_applications_service_spec.rb, which stubs this method
# for every example
describe ImportApplicationsService, ".open_url_safe" do
  include WebMock::API

  let(:logger) { Logger.new(File::NULL) }
  let(:url) { "https://api.morph.io/planningalerts-scrapers/exampleton/data.json" }

  it "returns what the url serves" do
    stub_request(:get, url).to_return(body: "[]")

    expect(described_class.open_url_safe(url, logger)).to eq "[]"
  end

  it "logs and returns nothing when the request fails, so the import skips that authority" do
    stub_request(:get, url).to_return(status: 500)
    allow(logger).to receive(:error)

    expect(described_class.open_url_safe(url, logger)).to be_nil
    expect(logger).to have_received(:error).with(/while getting data from url #{Regexp.escape(url)}/)
  end
end
