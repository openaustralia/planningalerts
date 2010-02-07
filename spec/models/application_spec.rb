require 'spec_helper'

describe Application do
  before :each do
    @auth = Authority.create!(:planning_email => "foo", :full_name => "Fiddlesticks", :short_name => "Fiddle")
  end
  
  describe "within" do
    it "should limit the results to those within the given area" do
      a1 = Application.create!(:lat => 2.0, :lng => 3.0, :authority_id => @auth.id, :postcode => "", :council_reference => "r1", :date_scraped => Date.today) # Within the box
      a2 = Application.create!(:lat => 4.0, :lng => 3.0, :authority_id => @auth.id, :postcode => "", :council_reference => "r2", :date_scraped => Date.today) # Outside the box
      a3 = Application.create!(:lat => 2.0, :lng => 1.0, :authority_id => @auth.id, :postcode => "", :council_reference => "r3", :date_scraped => Date.today) # Outside the box
      a4 = Application.create!(:lat => 1.5, :lng => 3.5, :authority_id => @auth.id, :postcode => "", :council_reference => "r4", :date_scraped => Date.today) # Within the box
      r = Application.within(Area.lower_left_and_upper_right(Location.new(1.0, 2.0), Location.new(3.0, 4.0)))
      r.count.should == 2
      r[0].should == a1
      r[1].should == a4
    end
  end
  
  describe "on saving" do
    it "should make a tinyurl version of the comment_url" do
      ShortURL.should_receive(:shorten).with("http://example.org/comment", :tinyurl).and_return("http://tinyurl.com/abcdef")
      a = Application.create!(:comment_url => "http://example.org/comment", :authority_id => @auth.id, :postcode => "", :council_reference => "r1", :date_scraped => Date.today)
      a.comment_tinyurl.should == "http://tinyurl.com/abcdef"
    end
    
    it "should make a tinyurl version of the info_url" do
      ShortURL.should_receive(:shorten).with("http://example.org/info", :tinyurl).and_return("http://tinyurl.com/1234")
      a = Application.create!(:info_url => "http://example.org/info", :authority_id => @auth.id, :postcode => "", :council_reference => "r1", :date_scraped => Date.today)
      a.info_tinyurl.should == "http://tinyurl.com/1234"      
    end
  end
end
