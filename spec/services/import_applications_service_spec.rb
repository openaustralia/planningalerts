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

  before :each do
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
    allow(ImportApplicationsService).to receive(:open_url_safe).and_return(
      [app_data1, app_data2].to_json
    )
  end

  it "should import the correct applications" do
    logger = double
    expect(logger).to receive(:info).with("2 applications found for Fiddlesticks, NSW with date from 2009-01-01 to 2009-01-01")
    expect(logger).to receive(:info).with("Took 0 s to import applications from Fiddlesticks, NSW")
    Timecop.freeze(date) do
      ImportApplicationsService.call(authority: auth, scrape_delay: 0, logger: logger, morph_api_key: "123")
    end
    expect(Application.count).to eq(2)
    r1 = Application.find_by(council_reference: "R1")
    expect(r1.date_scraped).to eq(date)
    expect(r1.authority).to eq(auth)
    expect(r1.address).to eq("1 Smith Street, Fiddleville")
    expect(r1.description).to eq("Knocking a house down")
    expect(r1.info_url).to eq("http://fiddle.gov.au/info/R1")
    expect(r1.date_received).to eq(date)
    expect(r1.on_notice_from).to eq(Date.new(2009, 1, 5))
    expect(r1.on_notice_to).to eq(Date.new(2009, 1, 19))
  end

  it "should update an application when it already exist" do
    logger = double
    expect(logger).to receive(:info).with("2 applications found for Fiddlesticks, NSW with date from 2009-01-01 to 2009-01-01")
    expect(logger).to receive(:info).with("1 application found for Fiddlesticks, NSW with date from 2009-01-01 to 2009-01-01")
    expect(logger).to receive(:info).twice.with("Took 0 s to import applications from Fiddlesticks, NSW")

    Timecop.freeze(date) do
      ImportApplicationsService.call(authority: auth, scrape_delay: 0, logger: logger, morph_api_key: "123")
      # Getting the feed again with updated content for one of the applicartions
      allow(ImportApplicationsService).to receive(:open_url_safe).and_return(
        [app_data2_updated].to_json
      )
      ImportApplicationsService.call(authority: auth, scrape_delay: 0, logger: logger, morph_api_key: "123")
    end
    expect(Application.count).to eq(2)
    r2 = Application.find_by(council_reference: "R2")
    expect(r2.versions.count).to eq 2
    expect(r2.description).to eq "Knocking a house down"
    expect(r2.first_version.description).to eq "Putting a house up"
  end

  it "should escape the morph api key and the sql query" do
    logger = double
    allow(logger).to receive(:info)
    expect(ImportApplicationsService).to receive(:open_url_safe).with(
      "https://api.morph.io//data.json?key=12%2F&query=select+%2A+from+%60data%60+where+%60date_scraped%60+%3E%3D+%272009-01-01%27+and+%60date_scraped%60+%3C%3D+%272009-01-01%27",
      logger
    )
    Timecop.freeze(date) do
      ImportApplicationsService.call(authority: auth, scrape_delay: 0, logger: logger, morph_api_key: "12/")
    end
  end

  describe "#morph_query" do
    it "should filter by the date range" do
      Timecop.freeze(date) do
        s = ImportApplicationsService.new(authority: auth, scrape_delay: 7, logger: nil, morph_api_key: "123")
        expect(s.morph_query).to eq "select * from `data` where `date_scraped` >= '2008-12-25' and `date_scraped` <= '2009-01-01'"
      end
    end

    context "scraper_authority_label is set on authority" do
      let(:auth) { create(:authority, scraper_authority_label: "foo") }

      it "should filter by the authority_label" do
        Timecop.freeze(date) do
          s = ImportApplicationsService.new(authority: auth, scrape_delay: 7, logger: nil, morph_api_key: "123")
          expect(s.morph_query).to eq "select * from `data` where `authority_label` = 'foo' and `date_scraped` >= '2008-12-25' and `date_scraped` <= '2009-01-01'"
        end
      end
    end
  end
end
