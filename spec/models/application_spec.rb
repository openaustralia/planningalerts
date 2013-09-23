require 'spec_helper'

describe Application do
  before :each do
    Authority.delete_all
    @auth = Authority.create!(:full_name => "Fiddlesticks", :state => "NSW", :short_name => "Fiddle")
    # Stub out the geocoder to return some arbitrary coordinates so that the tests can run quickly
    Location.stub!(:geocode).and_return(mock(:lat => 1.0, :lng => 2.0, :suburb => "Glenbrook", :state => "NSW",
      :postcode => "2773", :success => true))
  end

  describe "validation" do
    describe "date_scraped" do
      it { Factory.build(:application, :date_scraped => nil).should_not be_valid }
    end

    describe "council_reference" do
      let (:auth1) { Factory(:authority) }

      it { Factory.build(:application, :council_reference => "").should_not be_valid }

      context "one application already exists" do
        before :each do
          Factory.create(:application, :council_reference => "A01", :authority => auth1)
        end
        let(:auth2) { Factory(:authority, :full_name => "A second authority") }

        it { Factory.build(:application, :council_reference => "A01", :authority => auth1).should_not be_valid }
        it { Factory.build(:application, :council_reference => "A02", :authority => auth1).should be_valid }
        it { Factory.build(:application, :council_reference => "A01", :authority => auth2).should be_valid }
      end
    end

    describe "address" do
      it { Factory.build(:application, :address => "").should_not be_valid }
    end

    describe "description" do
      it { Factory.build(:application, :description => "").should_not be_valid }
    end

    describe "info_url" do
      it { Factory.build(:application, :info_url => "").should_not be_valid }
      it { Factory.build(:application, :info_url => "http://blah.com?p=1").should be_valid }
      it { Factory.build(:application, :info_url => "foo").should_not be_valid }
    end

    describe "comment_url" do
      it { Factory.build(:application, :comment_url => nil).should be_valid }
      it { Factory.build(:application, :comment_url => "http://blah.com?p=1").should be_valid }
      it { Factory.build(:application, :comment_url => "mailto:m@foo.com?subject=hello+sir").should be_valid }
      it { Factory.build(:application, :comment_url => "foo").should_not be_valid }
    end

    describe "date_received" do
      it { Factory.build(:application, :date_received => nil).should be_valid }

      context "the date today is 1 january 2001" do
        before :each do
          Date.stub!(:today).and_return(Date.new(2001,1,1))
        end
        it { Factory.build(:application, :date_received => Date.new(2002,1,1)).should_not be_valid }
        it { Factory.build(:application, :date_received => Date.new(2000,1,1)).should be_valid }
      end
    end

    describe "on_notice" do
      it { Factory.build(:application, :on_notice_from => nil, :on_notice_to => nil).should be_valid }
      it { Factory.build(:application, :on_notice_from => Date.new(2001,1,1), :on_notice_to => Date.new(2001,2,1)).should be_valid }
      it { Factory.build(:application, :on_notice_from => nil, :on_notice_to => Date.new(2001,2,1)).should be_valid }
      it { Factory.build(:application, :on_notice_from => Date.new(2001,1,1), :on_notice_to => nil).should be_valid }
      it { Factory.build(:application, :on_notice_from => Date.new(2001,2,1), :on_notice_to => Date.new(2001,1,1)).should_not be_valid }
    end
  end

  describe "getting DA descriptions" do
    it "should allow applications to be blank" do
      Application.new(:description => "").description.should == ""
    end

    it "should allow the application description to be nil" do
      Application.new(:description => nil).description.should be_nil
    end

    it "should start descriptions with a capital letter" do
      Application.new(:description => "a description").description.should == "A description"
    end

    it "should fix capitilisation of descriptions all in caps" do
      Application.new(:description => "DWELLING").description.should == "Dwelling"
    end

    it "should not capitalise descriptions that are partially in lowercase" do
      Application.new(:description => "To merge Owners Corporation").description.should == "To merge Owners Corporation"
    end

    it "should capitalise the first word of each sentence" do
      Application.new(:description => "A SENTENCE. ANOTHER SENTENCE").description.should == "A sentence. Another sentence"
    end

    it "should only capitalise the word if it's all lower case" do
      Application.new(:description => 'ab sentence. AB SENTENCE. aB sentence. Ab sentence').description.should ==  'Ab sentence. AB SENTENCE. aB sentence. Ab sentence'
    end

    it "should allow blank sentences" do
      Application.new(:description => "A poorly.    . formed sentence . \n").description.should ==  "A poorly. . Formed sentence. "
    end
  end

  describe "getting addresses" do
    it "should convert words to first letter capitalised form" do
      Application.new(:address => "1 KINGSTON AVENUE, PAKENHAM").address.should == "1 Kingston Avenue, Pakenham"
    end

    it "should not convert words that are not already all in upper case" do
      Application.new(:address => "In the paddock next to the radio telescope").address.should == "In the paddock next to the radio telescope"
    end

    it "should handle a mixed bag of lower and upper case" do
      Application.new(:address => "63 Kimberley drive, SHAILER PARK").address.should == "63 Kimberley drive, Shailer Park"
    end

    it "should not affect dashes in the address" do
      Application.new(:address => "63-81").address.should == "63-81"
    end

    it "should not affect abbreviations like the state names" do
      Application.new(:address => "1 KINGSTON AVENUE, PAKENHAM VIC 3810").address.should == "1 Kingston Avenue, Pakenham VIC 3810"
    end

    it "should not affect the state names" do
      Application.new(:address => "QLD VIC NSW SA ACT TAS WA NT").address.should == "QLD VIC NSW SA ACT TAS WA NT"
    end

    it "should not affect codes" do
      Application.new(:address => "R79813 24X").address.should == "R79813 24X"
    end
  end

  describe "on saving" do
    it "should geocode the address" do
      loc = mock("Location", :lat => -33.772609, :lng => 150.624263, :suburb => "Glenbrook", :state => "NSW",
        :postcode => "2773", :success => true)
      Location.should_receive(:geocode).with("24 Bruce Road, Glenbrook, NSW").and_return(loc)
      a = Factory(:application, :address => "24 Bruce Road, Glenbrook, NSW", :council_reference => "r1", :date_scraped => Time.now)
      a.lat.should == loc.lat
      a.lng.should == loc.lng
    end

    it "should log an error if the geocoder can't make sense of the address" do
      Location.should_receive(:geocode).with("dfjshd").and_return(mock("Location", :success => false))
      logger = mock("Logger")
      logger.should_receive(:error).with("Couldn't geocode address: dfjshd")
      # Ignore the warning message (from the tinyurl'ing)
      logger.stub!(:warn)

      a = Factory.build(:application, :address => "dfjshd", :council_reference => "r1", :date_scraped => Time.now)
      a.stub!(:logger).and_return(logger)

      a.save!
      a.lat.should be_nil
      a.lng.should be_nil
    end

    it "should set the url for showing the address on a google map" do
      a = Factory.build(:application, :address => "24 Bruce Road, Glenbrook, NSW", :council_reference => "r1", :date_scraped => Time.now)
      a.map_url.should == "http://maps.google.com/maps?q=24+Bruce+Road%2C+Glenbrook%2C+NSW&z=15"
    end
  end

  describe "collecting applications from the scraperwiki web service url" do
    it "should translate the data" do
      feed_data = <<-EOF
        [
          {
            "date_scraped": "2012-08-24",
            "description": "Construction of Dwelling",
            "info_url": "http://www.yarracity.vic.gov.au/Planning-Application-Search/Results.aspx?ApplicationNumber=PL01/0776.01&Suburb=(All)&Street=(All)&Status=(All)&Ward=(All)",
            "on_notice_from": "2012-05-01",
            "on_notice_to": "2012-06-01",
            "date_received": "2012-07-06",
            "council_reference": "PL01/0776.01",
            "address": "56 Murphy St Richmond VIC 3121",
            "comment_url": "http://www.yarracity.vic.gov.au/planning--building/Planning-applications/Objecting-to-a-planning-applicationVCAT/"
          },
          {
            "date_scraped": "2012-08-24",
            "description": "Liquor Licence for Existing Caf\u00e9",
            "info_url": "http://www.yarracity.vic.gov.au/Planning-Application-Search/Results.aspx?ApplicationNumber=PL02/0313.01&Suburb=(All)&Street=(All)&Status=(All)&Ward=(All)",
            "date_received": "2012-07-30",
            "council_reference": "PL02/0313.01",
            "address": "359-361 Napier St Fitzroy VIC 3065",
            "comment_url": "http://www.yarracity.vic.gov.au/planning--building/Planning-applications/Objecting-to-a-planning-applicationVCAT/"
          }
        ]
      EOF
      # Freeze time
      t = Time.now
      Time.stub!(:now).and_return(t)
      Application.translate_scraperwiki_feed_data(feed_data).should ==
      [
        {
          :date_scraped => t,
          :description => "Construction of Dwelling",
          :info_url => "http://www.yarracity.vic.gov.au/Planning-Application-Search/Results.aspx?ApplicationNumber=PL01/0776.01&Suburb=(All)&Street=(All)&Status=(All)&Ward=(All)",
          :on_notice_from => "2012-05-01",
          :on_notice_to => "2012-06-01",
          :date_received => "2012-07-06",
          :council_reference => "PL01/0776.01",
          :address => "56 Murphy St Richmond VIC 3121",
          :comment_url => "http://www.yarracity.vic.gov.au/planning--building/Planning-applications/Objecting-to-a-planning-applicationVCAT/"
        },
        {
          :date_scraped => t,
          :description => "Liquor Licence for Existing Caf\u00e9",
          :info_url => "http://www.yarracity.vic.gov.au/Planning-Application-Search/Results.aspx?ApplicationNumber=PL02/0313.01&Suburb=(All)&Street=(All)&Status=(All)&Ward=(All)",
          :on_notice_from => nil,
          :on_notice_to => nil,
          :date_received => "2012-07-30",
          :council_reference => "PL02/0313.01",
          :address => "359-361 Napier St Fitzroy VIC 3065",
          :comment_url => "http://www.yarracity.vic.gov.au/planning--building/Planning-applications/Objecting-to-a-planning-applicationVCAT/"
        }
      ]
    end

    it "should handle a malformed response" do
      Application.translate_scraperwiki_feed_data('[["An invalid scraperwiki API response"]]').should == []
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
            <date_received/>
            <on_notice_from></on_notice_from>
          </application>
        </applications>
      </planning>
      EOF
      @date = Date.new(2009, 1, 1)
      @feed_url = "http://example.org?year=#{@date.year}&month=#{@date.month}&day=#{@date.day}"
      @auth.stub!(:feed_url_for_date).and_return(@feed_url)
      Application.delete_all
      @auth.stub!(:open).and_return(mock(:read => @feed_xml))
    end

    it "should collect the correct applications" do
      logger = mock
      @auth.stub!(:logger).and_return(logger)
      logger.should_receive(:info).with("2 new applications found for Fiddlesticks, NSW with date from 2009-01-01 to 2009-01-01")

      @auth.collect_applications_date_range(@date, @date)
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
      @auth.stub!(:logger).and_return(logger)
      logger.should_receive(:info).with("2 new applications found for Fiddlesticks, NSW with date from 2009-01-01 to 2009-01-01")
      logger.should_receive(:info).with("0 new applications found for Fiddlesticks, NSW with date from 2009-01-01 to 2009-01-01")

      # Getting the feed twice with the same content
      @auth.collect_applications_date_range(@date, @date)
      @auth.collect_applications_date_range(@date, @date)
      Application.count.should == 2
    end

    it "should collect all the applications from all the authorities over the last n days" do
      auth2 = Authority.create!(:full_name => "Wombat City Council", :short_name => "Wombat", :state => "NSW")
      Date.stub!(:today).and_return(Date.new(2010, 1, 10))
      # Overwriting a constant here. Normally generates a warning. Silence it!
      Kernel::silence_warnings { ::Configuration::SCRAPE_DELAY = 1 }
      logger = mock
      logger.should_receive(:info).with("Scraping 2 authorities")
      #logger.should_receive(:add).with(1, nil, "Took 0 s to collect applications from Fiddlesticks, NSW")
      #logger.should_receive(:add).with(1, nil, "Took 0 s to collect applications from Wombat City Council, NSW")
      @auth.should_receive(:collect_applications).with(logger)
      auth2.should_receive(:collect_applications).with(logger)

      Application.collect_applications([@auth, auth2], logger)
    end
  end
end
