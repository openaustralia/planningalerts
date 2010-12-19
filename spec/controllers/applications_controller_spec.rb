require 'spec_helper'

describe ApplicationsController do
  describe "rss feed" do
    it "should provide a link for all applications" do
      get :index
      assigns[:rss].should == "http://test.host/applications.rss"
    end

    it "should provide a link to the search by address" do
      get :index, :address => "24 Bruce Road Glenbrook, NSW 2773", :radius => 4000
      assigns[:rss].should == "http://test.host/applications.rss?address=24+Bruce+Road+Glenbrook%2C+NSW+2773&radius=4000"
    end
    
    it "should not put the page parameter in the rss feed" do
      get :index, :address => "24 Bruce Road Glenbrook, NSW 2773", :radius => 4000, :page => 2
      assigns[:rss].should == "http://test.host/applications.rss?address=24+Bruce+Road+Glenbrook%2C+NSW+2773&radius=4000"      
    end
  end
  
  describe "index" do
    it "should find recent applications" do
      result = mock
      Application.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)
      get :index, :format => "rss"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications"
    end
  end
  
  describe "search by address" do
    before :each do
      location = mock(:lat => 1.0, :lng => 2.0, :full_address => "24 Bruce Road, Glenbrook NSW 2773")
      @result = mock

      Location.should_receive(:geocode).with("24 Bruce Road Glenbrook").and_return(location)
      Application.should_receive(:paginate).with(:origin => [location.lat, location.lng], :within => 4, :page => nil, :per_page => 100).and_return(@result)
    end
    
    it "should find recent applications near the address" do
      get :index, :format => "rss", :address => "24 Bruce Road Glenbrook", :radius => 4000
      assigns[:applications].should == @result
      # Should use the normalised form of the address in the description
      assigns[:description].should == "Recent applications within 4 km of 24 Bruce Road, Glenbrook NSW 2773"
    end

    it "should find recent applications near the address using the old parameter name" do
      get :index, :format => "rss", :address => "24 Bruce Road Glenbrook", :area_size => 4000
      assigns[:applications].should == @result
      assigns[:description].should == "Recent applications within 4 km of 24 Bruce Road, Glenbrook NSW 2773"
    end
  end
  
  describe "search by address no radius" do
    it "should use a search radius of 2000 when none is specified" do
      location = mock(:lat => 1.0, :lng => 2.0, :full_address => "24 Bruce Road, Glenbrook NSW 2773")
      result = mock

      Location.should_receive(:geocode).with("24 Bruce Road Glenbrook").and_return(location)
      Application.should_receive(:paginate).with(:origin => [location.lat, location.lng], :within => 2, :page => nil, :per_page => 100).and_return(result)

      get :index, :address => "24 Bruce Road Glenbrook"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications within 2 km of 24 Bruce Road, Glenbrook NSW 2773"      
    end
  end
  
  describe "search by point" do
    before :each do
      @result = mock

      Application.should_receive(:paginate).with(:origin => [1.0, 2.0], :within => 4, :page => nil, :per_page => 100).and_return(@result)
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
      result = mock

      Application.should_receive(:paginate).with(:bounds => [[1.0, 2.0], [3.0, 4.0]], :page => nil, :per_page => 100).and_return(result)

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
      scope.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)
      authority.should_receive(:full_name_and_state).and_return("Blue Mountains City Council")

      get :index, :format => "rss", :authority_id => "blue_mountains"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in Blue Mountains City Council"
    end
    
    it "should give a 404 when an invalid authority_id is used" do
      Authority.should_receive(:find_by_short_name_encoded).with("this_authority_does_not_exist").and_return(nil)
      
      lambda{get :index, :authority_id => "this_authority_does_not_exist"}.should raise_error ActiveRecord::RecordNotFound
    end
  end
  
  describe "search by postcode" do
    it "should find recent applications for a postcode" do
      result = mock

      Application.should_receive(:paginate).with(:conditions => {:postcode => "2780"}, :page => nil, :per_page => 100).and_return(result)
      get :index, :format => "rss", :postcode => "2780"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in postcode 2780"
    end
  end
  
  describe "search by suburb" do
    it "should find recent applications for a suburb" do
      result = mock
      Application.should_receive(:paginate).with(:conditions => {:suburb => "Katoomba"}, :page => nil, :per_page => 100).and_return(result)
      get :index, :format => "rss", :suburb => "Katoomba"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in Katoomba"
    end
  end
  
  describe "search by suburb and state" do
    it "should find recent applications for a suburb and state" do
      result = mock
      Application.should_receive(:paginate).with(:conditions => {:suburb => "Katoomba", :state => "NSW"}, :page => nil, :per_page => 100).and_return(result)
      get :index, :format => "rss", :suburb => "Katoomba", :state => "NSW"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in Katoomba, NSW"
    end
  end
  
  describe "show" do
    it "should gracefully handle an application without any geocoded information" do
      app = mock_model(Application, :address => "An address that can't be geocoded", :date_scraped => Date.new(2010,1,1),
        :description => "foo", :location => nil, :find_all_nearest_or_recent => [])
      Application.should_receive(:find).with("1").and_return(app)
      get :show, :id => 1
      
      assigns[:application].should == app
      assigns[:nearby_applications].should == []
    end
  end
  
  describe "search engine optimisation" do
    it "should provide a meta tag description so that the search results from search engines are more helpful and readable" do
      app = mock_model(Application, :address => "12 Foo Street", :date_scraped => Date.new(2010, 5, 13),
        :description => "Cutting a hedge.", :find_all_nearest_or_recent => [])
      Application.should_receive(:find).with("1").and_return(app)
      get :show, :id => 1

      assigns[:meta_description].should == "Planning application: Cutting a hedge. Address: 12 Foo Street"
    end
  end
  
  describe "mobile support" do
    it "should have a mobile optimised show page" do
      app = mock_model(Application, :address => "12 Foo Street", :date_scraped => Date.new(2010, 5, 13),
        :description => "Cutting a hedge.", :find_all_nearest_or_recent => [])
      Application.should_receive(:find).with("1").and_return(app)
      get :show, :id => 1
      assigns[:mobile_optimised].should == true
    end
    
    it "should disable mobile view" do
      get :show, :id => 1, :mobile => "false"
      session[:mobile_view].should be_false
      response.should redirect_to(:action => :show, :id => 1)
    end

    it "should enable mobile view" do
      get :show, :id => 1, :mobile => "true"
      session[:mobile_view].should be_true
      response.should redirect_to(:action => :show, :id => 1)
    end
  end
end
