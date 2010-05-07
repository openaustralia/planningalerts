require 'spec_helper'

describe ApplicationHelper do

  it "should convert a distance in metres to simple concise text" do
    helper.meters_in_words(2000).should == "2 km"
    helper.meters_in_words(500).should == "500 m"
  end
  
  describe "mobile_switcher_links" do
    it "should not be visible when a mobile-optimised page is viewed from a normal web browser (not a mobile)" do
      helper.stub!(:is_mobile_optimised?).and_return(true)
      helper.stub!(:is_mobile_device?).and_return(false)
      helper.mobile_switcher_links.should be_nil
    end

    it "should not be visible when a non mobile-optimised page is viewed" do
      helper.stub!(:is_mobile_optimised?).and_return(false)
      helper.mobile_switcher_links.should be_nil
    end
    
    it "should enable the classic link and disable the mobile link when we're currently in the mobile view" do
      helper.should_receive(:url_for).once.with(:mobile => "false").and_return("/foo/bar?mobile=false")
      helper.stub!(:is_mobile_optimised?).and_return(true)
      helper.stub!(:is_mobile_device?).and_return(true)
      helper.stub!(:in_mobile_view?).and_return(true)
      helper.mobile_switcher_links.should == 'Mobile | <a href="/foo/bar?mobile=false">Classic</a>'
    end

    it "should disable the classic link and enable the mobile link when we're currently in the classic view" do
      helper.should_receive(:url_for).once.with(:mobile => "true").and_return("/foo/bar?mobile=true")
      helper.stub!(:is_mobile_optimised?).and_return(true)
      helper.stub!(:is_mobile_device?).and_return(true)
      helper.stub!(:in_mobile_view?).and_return(false)
      helper.mobile_switcher_links.should == '<a href="/foo/bar?mobile=true">Mobile</a> | Classic'
    end
  end
end
