# frozen_string_literal: true

require "spec_helper"

describe ImportApplicationsService do
  let(:auth) { create(:authority, full_name: "Fiddlesticks", state: "NSW", short_name: "Fiddle") }
  let(:date) { Date.new(2009, 1, 1) }
  let(:app_data1) do
    {
      date_scraped: "2012-08-24",
      council_reference: "R1",
      address: "1 Smith Street, Fiddleville",
      description: "Knocking a house down",
      info_url: "http://fiddle.gov.au/info/R1",
      date_received: "2009-01-01",
      on_notice_from: "2009-01-05",
      on_notice_to: "2009-01-19"
    }
  end
  let(:app_data2) do
    {
      council_reference: "R2",
      address: "2 Smith Street, Fiddleville",
      description: "Putting a house up",
      info_url: "http://fiddle.gov.au/info/R2"
    }
  end
  let(:app_data2_updated) do
    app_data2.merge(description: "Knocking a house down")
  end

  before do
    # Stub out the geocoder to return some arbitrary coordinates so that the tests can run quickly
    allow(GeocodeService).to receive(:call).and_return(
      GeocoderResults.new(
        [
          GeocodedLocation.new(
            lat: 1.0,
            lng: 2.0,
            suburb: "Glenbrook",
            state: "NSW",
            postcode: "2773",
            full_address: "Glenbrook, NSW 2773"
          )
        ],
        nil
      )
    )
    allow(described_class).to receive(:open_url_safe).and_return(
      [app_data1, app_data2].to_json
    )
  end

  it "imports the correct applications" do
    logger = Logger.new($stdout)
    allow(logger).to receive(:info)
    allow(ENV).to receive(:fetch)
    allow(ENV).to receive(:fetch).with("SCRAPE_DELAY", nil).and_return(0)
    allow(ENV).to receive(:fetch).with("MORPH_API_KEY", nil).and_return("123")
    allow(SyncGithubIssueForAuthorityService).to receive(:call)

    Timecop.freeze(date) do
      described_class.call(authority: auth, logger:)
    end
    expect(logger).to have_received(:info).with("2 applications found for Fiddlesticks, NSW with date from 2009-01-01")
    expect(logger).to have_received(:info).with("Took 0 s to import applications from Fiddlesticks, NSW")
    expect(SyncGithubIssueForAuthorityService).to have_received(:call).with(logger:, authority: auth)
    expect(Application.count).to eq(2)
    r1 = Application.find_by(council_reference: "R1")
    expect(r1.first_date_scraped).to eq(date)
    expect(r1.authority).to eq(auth)
    expect(r1.address).to eq("1 Smith Street, Fiddleville")
    expect(r1.description).to eq("Knocking a house down")
    expect(r1.info_url).to eq("http://fiddle.gov.au/info/R1")
    expect(r1.date_received).to eq(date)
    expect(r1.on_notice_from).to eq(Date.new(2009, 1, 5))
    expect(r1.on_notice_to).to eq(Date.new(2009, 1, 19))
  end

  it "updates an application when it already exist" do
    logger = Logger.new($stdout)
    allow(logger).to receive(:info)
    allow(ENV).to receive(:fetch)
    allow(ENV).to receive(:fetch).with("SCRAPE_DELAY", nil).and_return(0)
    allow(ENV).to receive(:fetch).with("MORPH_API_KEY", nil).and_return("123")
    allow(SyncGithubIssueForAuthorityService).to receive(:call).with(logger:, authority: auth)

    Timecop.freeze(date) do
      described_class.call(authority: auth, logger:)
      # Getting the feed again with updated content for one of the applicartions
      allow(described_class).to receive(:open_url_safe).and_return(
        [app_data2_updated].to_json
      )
      described_class.call(authority: auth, logger:)
    end

    expect(logger).to have_received(:info).with("2 applications found for Fiddlesticks, NSW with date from 2009-01-01")
    expect(logger).to have_received(:info).with("1 application found for Fiddlesticks, NSW with date from 2009-01-01")
    expect(logger).to have_received(:info).twice.with("Took 0 s to import applications from Fiddlesticks, NSW")
    expect(Application.count).to eq(2)
    r2 = Application.find_by(council_reference: "R2")
    expect(r2.versions.count).to eq 2
    expect(r2.description).to eq "Knocking a house down"
    expect(r2.first_version.description).to eq "Putting a house up"
  end

  it "escapes the morph api key and the sql query" do
    logger = Logger.new($stdout)
    allow(logger).to receive(:info)
    allow(ENV).to receive(:fetch)
    allow(ENV).to receive(:fetch).with("SCRAPE_DELAY", nil).and_return(0)
    allow(ENV).to receive(:fetch).with("MORPH_API_KEY", nil).and_return("12/")
    allow(SyncGithubIssueForAuthorityService).to receive(:call)

    Timecop.freeze(date) do
      described_class.call(authority: auth, logger:)
    end

    expect(described_class).to have_received(:open_url_safe).with(
      "https://api.morph.io//data.json?key=12%2F&query=select+%2A+from+%60data%60+where+%60date_scraped%60+%3E%3D+%272009-01-01%27",
      logger
    )
    expect(SyncGithubIssueForAuthorityService).to have_received(:call).with(logger:, authority: auth)
  end

  describe "#morph_query" do
    it "filters by the date range" do
      allow(ENV).to receive(:fetch).with("SCRAPE_DELAY", nil).and_return(7)
      allow(ENV).to receive(:fetch).with("MORPH_API_KEY", nil).and_return("")
      Timecop.freeze(date) do
        s = described_class.new(authority: auth, logger: Logger.new($stdout))
        expect(s.morph_query).to eq "select * from `data` where `date_scraped` >= '2008-12-25'"
      end
    end

    context "with scraper_authority_label is set on authority" do
      let(:auth) { create(:authority, scraper_authority_label: "foo") }

      it "filters by the authority_label" do
        allow(ENV).to receive(:fetch).with("SCRAPE_DELAY", nil).and_return(7)
        allow(ENV).to receive(:fetch).with("MORPH_API_KEY", nil).and_return("")
        Timecop.freeze(date) do
          s = described_class.new(authority: auth, logger: Logger.new($stdout))
          expect(s.morph_query).to eq "select * from `data` where `authority_label` = 'foo' and `date_scraped` >= '2008-12-25'"
        end
      end
    end
  end
end
