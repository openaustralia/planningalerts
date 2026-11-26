# frozen_string_literal: true

require "spec_helper"

describe ImportApplicationsJob do
  let(:authority) { create(:authority, last_scraper_run_log: "The previous run's log") }

  # The service fetches from morph.io, so stand in for it and log like it does
  before do
    allow(ImportApplicationsService).to receive(:call) do |logger:, **|
      logger.info("Imported 2 applications")
    end
  end

  it "imports the authority's applications from its scraper" do
    described_class.new.perform(authority.id)

    expect(ImportApplicationsService).to have_received(:call)
      .with(authority:, logger: an_instance_of(AuthorityLogger), scrape_delay: 5, morph_api_key: anything)
  end

  it "refuses to import without a morph.io API key, saying how to set one" do
    allow(Rails.configuration.x).to receive(:morph_api_key).and_return(nil)

    expect { described_class.new.perform(authority.id) }.to raise_error(/MORPH_API_KEY in \.env/)
    expect(ImportApplicationsService).not_to have_received(:call)
  end

  it "replaces the authority's import log with this run's" do
    described_class.new.perform(authority.id)

    expect(authority.reload.last_scraper_run_log).to eq "Imported 2 applications\n"
  end
end
