require 'spec_helper'

describe Authority do
  describe "load_from_web_service" do
    it "should load all the authorities data from the scraper web service index" do
      handle = mock("Handle")
      Authority.should_receive(:open).and_return(handle)
      handle.should_receive(:read).and_return(
        <<-EOF
        <scrapers> 
          <scraper> 
            <authority_name>Blue Mountains City Council, NSW</authority_name> 
            <authority_short_name>Blue Mountains</authority_short_name> 
            <url>http://localhost:4567/blue_mountains?year={year}&amp;month={month}&amp;day={day}</url> 
          </scraper> 
          <scraper> 
            <authority_name>Brisbane City Council, QLD</authority_name> 
            <authority_short_name>Brisbane</authority_short_name> 
            <url>http://localhost:4567/brisbane?year={year}&amp;month={month}&amp;day={day}</url> 
          </scraper> 
        <scrapers>
        EOF
      )
      logger = mock("Logger")
      Authority.stub!(:logger).and_return(logger)
      logger.should_receive(:info).with("New authority: Blue Mountains")
      logger.should_receive(:info).with("New authority: Brisbane")

      Authority.delete_all
      Authority.load_from_web_service
      Authority.count.should == 2
      r = Authority.find_by_short_name("Blue Mountains")
      r.full_name.should == "Blue Mountains City Council, NSW"
      r.feed_url == "http://localhost:4567/blue_mountains?year={year}&month={month}&day={day}"
      r = Authority.find_by_short_name("Brisbane")
      r.full_name.should == "Brisbane City Council, QLD"
      r.feed_url == "http://localhost:4567/brisbane?year={year}&month={month}&day={day}"
    end
  end
  
  it "should substitute the date in the url" do
    a = Authority.new(:feed_url => "http://example.org?year={year}&month={month}&day={day}")
    date = Date.new(2009, 2, 1)
    a.feed_url_for_date(date).should == "http://example.org?year=2009&month=2&day=1"
  end
  
  describe "short name encoded" do
    before :each do
      @a1 = Authority.create!(:short_name => "Blue Mountains", :full_name => "Blue Mountains City Council")
      @a2 = Authority.create!(:short_name => "Blue Mountains (new one)", :full_name => "Blue Mountains City Council (fictional new one)")
    end
    
    it "should be constructed by replacing space by underscores and making it all lowercase" do
      @a1.short_name_encoded.should == "blue_mountains"
    end
    
    it "should remove any non-word characters (except for underscore)" do
      @a2.short_name_encoded.should == "blue_mountains_new_one"
    end
    
    it "should find a authority by the encoded name" do
      Authority.find_by_short_name_encoded("blue_mountains").should == @a1
      Authority.find_by_short_name_encoded("blue_mountains_new_one").should == @a2
    end
  end
end