require 'spec_helper'

describe Application do
  before :each do
    @auth = Authority.create!(:planning_email => "foo", :full_name => "Fiddlesticks", :short_name => "Fiddle")
    # Stub out the geocoder to return some arbitrary coordinates so that the tests can run quickly
    Location.stub!(:geocode).and_return(mock(:lat => 1.0, :lng => 2.0, :success => true))
  end
  
  describe "within" do
    it "should limit the results to those within the given area" do
      a1 = @auth.applications.create!(:lat => 2.0, :lng => 3.0, :postcode => "", :council_reference => "r1") # Within the box
      a2 = @auth.applications.create!(:lat => 4.0, :lng => 3.0, :postcode => "", :council_reference => "r2") # Outside the box
      a3 = @auth.applications.create!(:lat => 2.0, :lng => 1.0, :postcode => "", :council_reference => "r3") # Outside the box
      a4 = @auth.applications.create!(:lat => 1.5, :lng => 3.5, :postcode => "", :council_reference => "r4") # Within the box
      r = Application.within(Area.lower_left_and_upper_right(Location.new(1.0, 2.0), Location.new(3.0, 4.0)))
      r.count.should == 2
      r[0].should == a1
      r[1].should == a4
    end
  end
  
  describe "on saving" do
    it "should set the date_scraped to the current time and date" do
      date = DateTime.civil(2009,1,1)
      DateTime.should_receive(:now).and_return(date)
      a = @auth.applications.create!(:postcode => "", :council_reference => "r1")
      a.date_scraped.utc.should == date
    end
    
    it "should make a tinyurl version of the comment_url" do
      ShortURL.should_receive(:shorten).with("http://example.org/comment", :tinyurl).and_return("http://tinyurl.com/abcdef")
      a = @auth.applications.create!(:comment_url => "http://example.org/comment", :postcode => "", :council_reference => "r1")
      a.comment_tinyurl.should == "http://tinyurl.com/abcdef"
    end
    
    it "should make a tinyurl version of the info_url" do
      ShortURL.should_receive(:shorten).with("http://example.org/info", :tinyurl).and_return("http://tinyurl.com/1234")
      a = @auth.applications.create!(:info_url => "http://example.org/info", :postcode => "", :council_reference => "r1")
      a.info_tinyurl.should == "http://tinyurl.com/1234"      
    end
    
    it "should geocode the address" do
      loc = mock("Location", :lat => -33.772609, :lng => 150.624263, :success => true)
      Location.should_receive(:geocode).with("24 Bruce Road, Glenbrook, NSW").and_return(loc)
      a = @auth.applications.create!(:address => "24 Bruce Road, Glenbrook, NSW", :postcode => "", :council_reference => "r1")
      a.lat.should == loc.lat
      a.lng.should == loc.lng
    end
    
    it "should log an error if the geocoder can't make sense of the address" do
      Location.should_receive(:geocode).with("dfjshd").and_return(mock("Location", :success => false))
      logger = mock("Logger")
      logger.should_receive(:error).with("Couldn't geocode address: dfjshd")
      # Ignore the warning message (from the tinyurl'ing)
      logger.stub!(:warn)

      a = @auth.applications.new(:address => "dfjshd", :postcode => "", :council_reference => "r1")
      a.stub!(:logger).and_return(logger)
      
      a.save!
      a.lat.should be_nil
      a.lng.should be_nil
    end
    
    it "should set the url for showing the address on a google map" do
      a = @auth.applications.create!(:address => "24 Bruce Road, Glenbrook, NSW", :postcode => "", :council_reference => "r1")
      a.map_url.should == "http://maps.google.com/maps?q=24+Bruce+Road%2C+Glenbrook%2C+NSW&z=15"
    end
  end
end
