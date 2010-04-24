require 'spec_helper'

describe ApplicationsController do
  describe "named_scope recent" do
    it "should scope the query to return the most recent 100 applications" do
      Application.recent.proxy_options.should == {:limit => 100, :order => "date_scraped DESC"}
    end
  end
  
  describe "rss feed" do
    it "should provide a link for all applications" do
      get :index
      assigns[:rss].should == "http://test.host/applications.rss"
    end

    it "should provide a link to the search by address" do
      get :index, :address => "24 Bruce Road Glenbrook, NSW 2773", :area_size => 4000
      assigns[:rss].should == "http://test.host/applications.rss?address=24+Bruce+Road+Glenbrook%2C+NSW+2773&area_size=4000"
    end
  end
  
  describe "index" do
    it "should find recent applications" do
      result = mock
      Application.should_receive(:recent).and_return(result)
      get :index, :format => "rss"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications"
    end
  end
  
  describe "search by address" do
    before :each do
      location = mock(:lat => 1.0, :lng => 2.0)
      scope, @result = mock, mock

      Location.should_receive(:geocode).with("24 Bruce Road Glenbrook, NSW 2773").and_return(location)
      Application.should_receive(:recent).and_return(scope)
      scope.should_receive(:find).with(:all, :origin => [location.lat, location.lng], :within => 4).and_return(@result)
    end
    
    it "should find recent applications near the address" do
      get :index, :format => "rss", :address => "24 Bruce Road Glenbrook, NSW 2773", :radius => 4000
      assigns[:applications].should == @result
      assigns[:description].should == "Recent applications within 4 km of 24 Bruce Road Glenbrook, NSW 2773"
    end

    it "should find recent applications near the address using the old parameter name" do
      get :index, :format => "rss", :address => "24 Bruce Road Glenbrook, NSW 2773", :area_size => 4000
      assigns[:applications].should == @result
      assigns[:description].should == "Recent applications within 4 km of 24 Bruce Road Glenbrook, NSW 2773"
    end
  end
  
  describe "search by point" do
    before :each do
      scope, @result = mock, mock

      Application.should_receive(:recent).and_return(scope)
      scope.should_receive(:find).with(:all, :origin => [1.0, 2.0], :within => 4).and_return(@result)
    end

    it "should find recent applications near the point" do
      get :index, :format => "rss", :lat => 1.0, :lng => 2.0, :radius => 4000
      assigns[:applications].should == @result
      assigns[:description].should == "Recent applications within 4 km of 1.0,2.0"
    end

    it "should find recent applications near the point using the old parameter name" do
      get :index, :format => "rss", :lat => 1.0, :lng => 2.0, :area_size => 4000
      assigns[:applications].should == @result
      assigns[:description].should == "Recent applications within 4 km of 1.0,2.0"
    end
  end
  
  describe "search by area" do
    it "should find recent applications in an area" do
      scope, result = mock, mock

      Application.should_receive(:recent).and_return(scope)
      scope.should_receive(:find).with(:all, :bounds => [[1.0, 2.0], [3.0, 4.0]]).and_return(result)

      get :index, :format => "rss", :bottom_left_lat => 1.0, :bottom_left_lng => 2.0,
        :top_right_lat => 3.0, :top_right_lng => 4.0
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in the area (1.0,2.0) (3.0,4.0)"
    end
  end
  
  describe "search by authority" do
    it "should find recent applications for an authority" do
      authority, result, scope = mock, mock, mock
      
      Authority.should_receive(:find_by_short_name_encoded).with("blue_mountains").and_return(authority)
      authority.should_receive(:applications).and_return(scope)
      scope.should_receive(:recent).and_return(result)
      authority.should_receive(:full_name).and_return("Blue Mountains City Council")

      get :index, :format => "rss", :authority_id => "blue_mountains"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in Blue Mountains City Council"
    end
  end
  
  describe "search by postcode" do
    it "should find recent applications for a postcode" do
      result, scope = mock, mock

      Application.should_receive(:recent).and_return(scope)
      scope.should_receive(:find_all_by_postcode).with("2780").and_return(result)
      get :index, :format => "rss", :postcode => "2780"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in postcode 2780"
    end
  end
  
  describe "search by suburb" do
    it "should find recent applications for a suburb" do
      result, scope = mock, mock
      Application.should_receive(:recent).and_return(scope)
      scope.should_receive(:find_all_by_suburb).with("Katoomba").and_return(result)
      get :index, :format => "rss", :suburb => "Katoomba"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in Katoomba"
    end
  end
  
  describe "search by suburb and state" do
    it "should find recent applications for a suburb and state" do
      result, scope = mock, mock
      Application.should_receive(:recent).and_return(scope)
      scope.should_receive(:find_all_by_suburb_and_state).with("Katoomba", "NSW").and_return(result)
      get :index, :format => "rss", :suburb => "Katoomba", :state => "NSW"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in Katoomba, NSW"
    end
  end
  
  describe "show" do
    it "should gracefully handle an application without any geocoded information" do
      app = mock_model(Application, :address => "An address that can't be geocoded", :location => nil)
      Application.should_receive(:find).with("1").and_return(app)
      get :show, :id => 1
      
      assigns[:application].should == app
      assigns[:page_title].should == "An address that can't be geocoded"
      assigns[:nearby_distance].should == 10000
      assigns[:nearby_applications].should == []
    end
  end
end
