require 'spec_helper'

describe Application do
  before :each do
    Authority.delete_all
    @auth = Authority.create!(:full_name => "Fiddlesticks", :short_name => "Fiddle")
    # Stub out the geocoder to return some arbitrary coordinates so that the tests can run quickly
    Location.stub!(:geocode).and_return(mock(:lat => 1.0, :lng => 2.0, :suburb => "Glenbrook", :state => "NSW",
      :postcode => "2773", :success => true))
  end
  
  describe "on saving" do
    it "should geocode the address" do
      loc = mock("Location", :lat => -33.772609, :lng => 150.624263, :suburb => "Glenbrook", :state => "NSW",
        :postcode => "2773", :success => true)
      Location.should_receive(:geocode).with("24 Bruce Road, Glenbrook, NSW").and_return(loc)
      a = @auth.applications.create!(:address => "24 Bruce Road, Glenbrook, NSW", :council_reference => "r1", :date_scraped => Time.now)
      a.lat.should == loc.lat
      a.lng.should == loc.lng
    end
    
    it "should log an error if the geocoder can't make sense of the address" do
      Location.should_receive(:geocode).with("dfjshd").and_return(mock("Location", :success => false))
      logger = mock("Logger")
      logger.should_receive(:error).with("Couldn't geocode address: dfjshd")
      # Ignore the warning message (from the tinyurl'ing)
      logger.stub!(:warn)

      a = @auth.applications.new(:address => "dfjshd", :council_reference => "r1", :date_scraped => Time.now)
      a.stub!(:logger).and_return(logger)
      
      a.save!
      a.lat.should be_nil
      a.lng.should be_nil
    end
    
    it "should set the url for showing the address on a google map" do
      a = @auth.applications.create!(:address => "24 Bruce Road, Glenbrook, NSW", :council_reference => "r1", :date_scraped => Time.now)
      a.map_url.should == "http://maps.google.com/maps?q=24+Bruce+Road%2C+Glenbrook%2C+NSW&z=15"
    end
  end
  
  describe "collecting applications from the scraper web service urls" do
    before :each do
      @feed_xml = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <planning>
        <authority_name>Fiddlesticks</authority_name>
        <authority_short_name>Fiddle</authority_short_name>
        <applications>
          <application>
            <council_reference>R1</council_reference>
            <address>1 Smith Street, Fiddleville</address>
            <description>Knocking a house down</description>
            <info_url>http://fiddle.gov.au/info/R1</info_url>
            <comment_url>http://fiddle.gov.au/comment/R1</comment_url>
            <date_received>2009-01-01</date_received>
            <on_notice_from>2009-01-05</on_notice_from>
            <on_notice_to>2009-01-19</on_notice_to>
          </application>
          <application>
            <council_reference>R2</council_reference>
            <address>2 Smith Street, Fiddleville</address>
            <description>Putting a house up</description>
            <info_url>http://fiddle.gov.au/info/R2</info_url>
            <comment_url>http://fiddle.gov.au/comment/R2</comment_url>
            <date_received>2009-01-01</date_received>
          </application>
        </applications>
      </planning>
      EOF
      @date = Date.new(2009, 1, 1)
      @feed_url = "http://example.org?year=#{@date.year}&month=#{@date.month}&day=#{@date.day}"
      @auth.stub!(:feed_url_for_date).and_return(@feed_url)
      Application.delete_all
      Application.stub!(:open).and_return(mock(:read => @feed_xml))
    end
    
    it "should collect the correct applications" do
      logger = mock
      Application.stub!(:logger).and_return(logger)
      logger.should_receive(:info).with("2 new applications found for Fiddlesticks")
      
      Application.collect_applications_for_authority(@auth, @date)
      Application.count.should == 2
      r1 = Application.find_by_council_reference("R1")
      r1.authority.should == @auth
      r1.address.should == "1 Smith Street, Fiddleville"
      r1.description.should == "Knocking a house down"
      r1.info_url.should == "http://fiddle.gov.au/info/R1"
      r1.comment_url.should == "http://fiddle.gov.au/comment/R1"
      r1.date_received.should == @date
      r1.on_notice_from.should == Date.new(2009,1,5)
      r1.on_notice_to.should == Date.new(2009,1,19)
    end
    
    it "should not create new applications when they already exist" do
      logger = mock
      Application.stub!(:logger).and_return(logger)
      logger.should_receive(:info).with("2 new applications found for Fiddlesticks")
      # It shouldn't log anything if there are no new applications

      # Getting the feed twice with the same content
      Application.collect_applications_for_authority(@auth, @date)
      Application.collect_applications_for_authority(@auth, @date)
      Application.count.should == 2
    end
    
    it "should collect all the applications from all the authorities over the last n days" do
      auth2 = Authority.create!(:full_name => "Wombat City Council", :short_name => "Wombat")
      Date.stub!(:today).and_return(Date.new(2010, 1, 10))
      # TODO Overwriting a constant here. Ugh. Do this better
      Configuration::SCRAPE_DELAY = 1
      logger = mock
      logger.should_receive(:info).with("Scraping 2 authorities with date 2010-01-10")
      logger.should_receive(:info).with("Scraping 2 authorities with date 2010-01-09")
      Application.should_receive(:collect_applications_for_authority).with(@auth, Date.today, logger)
      Application.should_receive(:collect_applications_for_authority).with(auth2, Date.today, logger)
      Application.should_receive(:collect_applications_for_authority).with(@auth, Date.today - 1, logger)
      Application.should_receive(:collect_applications_for_authority).with(auth2, Date.today - 1, logger)

      Application.collect_applications(logger)
    end
  end
end
