# frozen_string_literal: true

require "spec_helper"

describe ImportApplicationsService do
  before :each do
    Authority.delete_all
    @auth = create(:authority, full_name: "Fiddlesticks", state: "NSW", short_name: "Fiddle")
    # Stub out the geocoder to return some arbitrary coordinates so that the tests can run quickly
    allow(Geocoder).to receive(:geocode).and_return(
      double(lat: 1.0, lng: 2.0, suburb: "Glenbrook", state: "NSW",
             postcode: "2773", success: true)
    )
  end

  describe "importing applications from the scraper web service urls" do
    before :each do
      feed = <<-JSON
      [
        {
          "date_scraped": "2012-08-24",
          "council_reference": "R1",
          "address": "1 Smith Street, Fiddleville",
          "description": "Knocking a house down",
          "info_url": "http://fiddle.gov.au/info/R1",
          "comment_url": "http://fiddle.gov.au/comment/R1",
          "date_received": "2009-01-01",
          "on_notice_from": "2009-01-05",
          "on_notice_to": "2009-01-19"
        },
        {
          "council_reference": "R2",
          "address": "2 Smith Street, Fiddleville",
          "description": "Putting a house up",
          "info_url": "http://fiddle.gov.au/info/R2",
          "comment_url": "http://fiddle.gov.au/comment/R2"
        }
      ]
      JSON
      @date = Date.new(2009, 1, 1)
      Application.delete_all
      allow(ImportApplicationsService).to receive(:open_url_safe).and_return(feed)
    end

    it "should import the correct applications" do
      logger = double
      expect(logger).to receive(:info).with("2 new applications found for Fiddlesticks, NSW with date from 2009-01-01 to 2009-01-01")
      expect(logger).to receive(:info).with("Took 0 s to import applications from Fiddlesticks, NSW")
      Timecop.freeze(@date) do
        ImportApplicationsService.call(authority: @auth, scrape_delay: 0, logger: logger)
      end
      expect(Application.count).to eq(2)
      r1 = Application.find_by(council_reference: "R1")
      expect(r1.date_scraped).to eq(@date)
      expect(r1.authority).to eq(@auth)
      expect(r1.address).to eq("1 Smith Street, Fiddleville")
      expect(r1.description).to eq("Knocking a house down")
      expect(r1.info_url).to eq("http://fiddle.gov.au/info/R1")
      expect(r1.comment_url).to eq("http://fiddle.gov.au/comment/R1")
      expect(r1.date_received).to eq(@date)
      expect(r1.on_notice_from).to eq(Date.new(2009, 1, 5))
      expect(r1.on_notice_to).to eq(Date.new(2009, 1, 19))
    end

    it "should not create new applications when they already exist" do
      logger = double
      expect(logger).to receive(:info).with("2 new applications found for Fiddlesticks, NSW with date from 2009-01-01 to 2009-01-01")
      expect(logger).to receive(:info).with("0 new applications found for Fiddlesticks, NSW with date from 2009-01-01 to 2009-01-01")
      expect(logger).to receive(:info).twice.with("Took 0 s to import applications from Fiddlesticks, NSW")

      # Getting the feed twice with the same content
      Timecop.freeze(@date) do
        ImportApplicationsService.call(authority: @auth, scrape_delay: 0, logger: logger)
        ImportApplicationsService.call(authority: @auth, scrape_delay: 0, logger: logger)
      end
      expect(Application.count).to eq(2)
    end
  end
end
