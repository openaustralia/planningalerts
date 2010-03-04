require 'spec_helper'

describe ApplicationsController do
  describe "search by address" do
    it "should find recent 100 applications near the address with the most recently scraped first" do
      location, area, scope, result = mock, mock, mock, mock
      
      Location.should_receive(:geocode).with("24 Bruce Road Glenbrook, NSW 2773").and_return(location)
      Area.should_receive(:centre_and_size).with(location, 4000).and_return(area)
      Application.should_receive(:within).with(area).and_return(scope)
      scope.should_receive(:find).with(:all, {:limit=>100, :order=>"date_scraped DESC"}).and_return(result)
      get :index, :format => "rss", :address => "24 Bruce Road Glenbrook, NSW 2773", :area_size => 4000
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications within 4 km of 24 Bruce Road Glenbrook, NSW 2773"
    end
  end
  
  describe "search by point" do
    it "should find recent 100 applications near the point with the most recently scraped first" do
      area, scope, result = mock, mock, mock

      Area.should_receive(:centre_and_size).with(Location.new(1.0, 2.0), 4000).and_return(area)
      Application.should_receive(:within).with(area).and_return(scope)
      scope.should_receive(:find).with(:all, {:limit=>100, :order=>"date_scraped DESC"}).and_return(result)
      
      get :index, :format => "rss", :lat => 1.0, :lng => 2.0, :area_size => 4000
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications within 4 km of 1.0, 2.0"
    end
  end
  
  describe "search by area" do
    it "should find recent 100 applications in an area with the most recently scraped first" do
      area, scope, result = mock, mock, mock

      Area.should_receive(:lower_left_and_upper_right).with(Location.new(1.0, 2.0), Location.new(3.0, 4.0)).and_return(area)
      Application.should_receive(:within).with(area).and_return(scope)
      scope.should_receive(:find).with(:all, {:limit=>100, :order=>"date_scraped DESC"}).and_return(result)

      get :index, :format => "rss", :bottom_left_lat => 1.0, :bottom_left_lng => 2.0,
        :top_right_lat => 3.0, :top_right_lng => 4.0
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications within the area (1.0, 2.0) (3.0, 4.0)"
    end
  end
  
  describe "search by authority" do
    it "should find recent 100 applications for an authority with the most recently scraped first" do
      authority, result = mock, mock

      Authority.should_receive(:find_by_short_name).with("Blue Mountains").and_return(authority)
      authority.should_receive(:applications).with(:limit=>100, :order=>"date_scraped DESC").and_return(result)
      authority.should_receive(:full_name).and_return("Blue Mountains City Council")

      get :index, :format => "rss", :authority_id => "Blue Mountains"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications within Blue Mountains City Council"
    end
  end
end
