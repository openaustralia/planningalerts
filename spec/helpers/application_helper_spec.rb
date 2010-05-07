require 'spec_helper'

describe ApplicationHelper do

  it "should convert a distance in metres to simple concise text" do
    helper.meters_in_words(2000).should == "2 km"
    helper.meters_in_words(500).should == "500 m"
  end
  
  it "should round distances in km to the nearest 100m" do
    helper.meters_in_words(2345).should == "2.3 km"
  end
  
  it "should round distances in metres to nearest 10m" do
    helper.meters_in_words(923.45).should == "920 m"
  end
  
  it "should round distances less than 100 metres to nearest metre" do
    helper.meters_in_words(84.23).should == "84 m"
  end
  
  it "should round to two significant figures" do
    helper.significant_figure(0.164, 2).should == 0.16
    helper.significant_figure(1.64, 2).should == 1.6
    helper.significant_figure(16.4, 2).should == 16
    helper.significant_figure(164, 2).should == 160
    helper.significant_figure(1640, 2).should == 1600
  end

  it "should round to one significant figure" do
    helper.significant_figure(0.164, 1).should == 0.2
    helper.significant_figure(1.64, 1).should == 2
    helper.significant_figure(16.4, 1).should == 20
    helper.significant_figure(164, 1).should == 200
    helper.significant_figure(1640, 1).should == 2000
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
