require 'spec_helper'

describe Authority do
  describe "detecting authorities with old applications" do
    before :each do
      @a1 = create(:authority)
      @a2 = create(:authority)
      VCR.use_cassette('planningalerts') do
        create(:application, :authority => @a1, :date_scraped => 3.weeks.ago)
        create(:application, :authority => @a2)
      end
    end

    it "should report that a scraper is broken if it hasn't received a DA in over two weeks" do
      @a1.broken?.should == true
    end

    it "should not report that a scraper is broken if it has received a DA in less than two weeks" do
      @a2.broken?.should == false
    end
  end

  describe "short name encoded" do
    before :each do
      @a1 = create(:authority, short_name: "Blue Mountains", full_name: "Blue Mountains City Council")
      @a2 = create(:authority, short_name: "Blue Mountains (new one)", full_name: "Blue Mountains City Council (fictional new one)")
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

  describe "#scraper_data_original_style" do
    context "authority with an xml feed with no date in the url" do
      let (:authority) { Factory.build(:authority) }
      it "should get the feed date only once" do
        authority.should_receive(:open_url_safe).once
        authority.scraper_data_original_style("http://foo.com", Date.new(2001,1,1), Date.new(2001,1,3), double)
      end
    end
  end
end
