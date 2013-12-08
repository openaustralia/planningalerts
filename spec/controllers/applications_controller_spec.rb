require 'spec_helper'

describe ApplicationsController do
  describe "#index" do
    describe "rss feed" do
      before :each do
        Location.stub!(:geocode).and_return(mock(:lat => 1.0, :lng => 2.0, :full_address => "24 Bruce Road, Glenbrook NSW 2773"))
      end

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

    it "should find recent applications" do
      result = mock
      Application.stub_chain(:where, :paginate).and_return(result)
      get :index, :format => "rss"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications within the last 2 months"
    end

    describe "json api" do
      it "should find recent applications" do
        VCR.use_cassette('planningalerts') do
          result = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
          Application.stub_chain(:where, :paginate).and_return([result])
        end
        get :index, :format => "js"
        JSON.parse(response.body).should == [{
          "application" => {
            "id" => 10,
            "council_reference" => "001",
            "address" => "A test address",
            "on_notice_from" => nil,
            "on_notice_to" => nil,
            "authority" => {
              "full_name" => "Acme Local Planning Authority"
            },
            "no_alerted" => nil,
            "description" => "Pretty",
            "comment_url" => nil,
            "info_url" => "http://foo.com",
            "date_received" => nil,
            "lat" => nil,
            "lng" => nil,
            "date_scraped" => "2001-01-01T00:00:00Z",
          }
        }]
      end

      it "should support jsonp" do
        VCR.use_cassette('planningalerts') do
          result = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
          Application.stub_chain(:where, :paginate).and_return([result])
        end
        get :index, :format => "js", :callback => "foobar"
        response.body[0..6].should == "foobar("
        response.body[-1..-1].should == ")"
        JSON.parse(response.body[7..-2]).should == [{
          "application" => {
            "id" => 10,
            "council_reference" => "001",
            "address" => "A test address",
            "on_notice_from" => nil,
            "on_notice_to" => nil,
            "authority" => {
              "full_name" => "Acme Local Planning Authority"
            },
            "no_alerted" => nil,
            "description" => "Pretty",
            "comment_url" => nil,
            "info_url" => "http://foo.com",
            "date_received" => nil,
            "lat" => nil,
            "lng" => nil,
            "date_scraped" => "2001-01-01T00:00:00Z",
          }
        }]
      end
    end

    describe "json api version 2" do
      it "should find recent applications" do
        VCR.use_cassette('planningalerts') do
          application = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
          result = [application]
          result.stub!(:total_pages).and_return(5)
          Application.stub_chain(:where, :paginate).and_return(result)
        end
        get :index, :format => "js", :v => "2"
        JSON.parse(response.body).should == {
          "application_count" => 1,
          "page_count" => 5,
          "applications" => [{
            "application" => {
              "id" => 10,
              "council_reference" => "001",
              "address" => "A test address",
              "on_notice_from" => nil,
              "on_notice_to" => nil,
              "authority" => {
                "full_name" => "Acme Local Planning Authority"
              },
              "no_alerted" => nil,
              "description" => "Pretty",
              "comment_url" => nil,
              "info_url" => "http://foo.com",
              "date_received" => nil,
              "lat" => nil,
              "lng" => nil,
              "date_scraped" => "2001-01-01T00:00:00Z",
            }
          }]
        }
      end
    end

    describe "search by address" do
      before :each do
        location = mock(:lat => 1.0, :lng => 2.0, :full_address => "24 Bruce Road, Glenbrook NSW 2773")
        @result = mock

        Location.should_receive(:geocode).with("24 Bruce Road Glenbrook").and_return(location)
        Application.stub_chain(:near, :paginate).and_return(@result)
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

      #it "should log the api call" do
      #  get :index, :format => "rss", :address => "24 Bruce Road Glenbrook", :radius => 4000
      #  a = ApiStatistic.first
      #  a.ip_address.should == "0.0.0.0"
      #  a.query.should == "/applications.rss?address=24+Bruce+Road+Glenbrook&radius=4000"
      #end
    end

    describe "error checking on parameters used" do
      it "should error if some unknown parameters are included" do
        get :index, :format => "rss", :address => "24 Bruce Road Glenbrook", :radius => 4000, :foo => 200, :bar => "fiddle"
        response.body.should == "Bad request: Invalid parameter(s) used: bar, foo"
        response.code.should == "400"
      end

      it "should not do error checking on the normal html sites" do
        VCR.use_cassette('planningalerts') do
          get :index, :address => "24 Bruce Road Glenbrook", :radius => 4000, :foo => 200, :bar => "fiddle"
        end
        response.code.should == "200"
      end
    end
    
    describe "search by address no radius" do
      it "should use a search radius of 2000 when none is specified" do
        location = mock(:lat => 1.0, :lng => 2.0, :full_address => "24 Bruce Road, Glenbrook NSW 2773")
        result = mock

        Location.should_receive(:geocode).with("24 Bruce Road Glenbrook").and_return(location)
        Application.stub_chain(:near, :paginate).and_return(result)

        get :index, :address => "24 Bruce Road Glenbrook"
        assigns[:applications].should == result
        assigns[:description].should == "Recent applications within 2 km of 24 Bruce Road, Glenbrook NSW 2773"      
      end
    end
    
    describe "search by point" do
      before :each do
        @result = mock

        Application.stub_chain(:near, :paginate).and_return(@result)
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
        result, scope = mock, mock
        Application.should_receive(:where).with("lat > ? AND lng > ? AND lat < ? AND lng < ?", 1.0, 2.0, 3.0, 4.0).and_return(scope)
        scope.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)

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
        assigns[:description].should == "Recent applications from Blue Mountains City Council"
      end
      
      it "should give a 404 when an invalid authority_id is used" do
        Authority.should_receive(:find_by_short_name_encoded).with("this_authority_does_not_exist").and_return(nil)
        
        lambda{get :index, :authority_id => "this_authority_does_not_exist"}.should raise_error ActiveRecord::RecordNotFound
      end
    end
    
    describe "search by postcode" do
      it "should find recent applications for a postcode" do
        result, scope = mock, mock
        Application.should_receive(:where).with(:postcode => "2780").and_return(scope)
        scope.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)
        get :index, :format => "rss", :postcode => "2780"
        assigns[:applications].should == result
        assigns[:description].should == "Recent applications in postcode 2780"
      end
    end
    
    describe "search by suburb" do
      it "should find recent applications for a suburb" do
        result, scope = mock, mock
        Application.should_receive(:where).with(:suburb => "Katoomba").and_return(scope)
        scope.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)
        get :index, :format => "rss", :suburb => "Katoomba"
        assigns[:applications].should == result
        assigns[:description].should == "Recent applications in Katoomba"
      end
    end
    
    describe "search by suburb and state" do
      it "should find recent applications for a suburb and state" do
        result, scope = mock, mock
        Application.should_receive(:where).with(:suburb => "Katoomba", :state => "NSW").and_return(scope)
        scope.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)
        get :index, :format => "rss", :suburb => "Katoomba", :state => "NSW"
        assigns[:applications].should == result
        assigns[:description].should == "Recent applications in Katoomba, NSW"
      end
    end
    
  end
  
  describe "#show" do
    it "should gracefully handle an application without any geocoded information" do
      app = mock_model(Application, :address => "An address that can't be geocoded", :date_scraped => Date.new(2010,1,1),
        :description => "foo", :location => nil, :find_all_nearest_or_recent => [])
      Application.should_receive(:find).with("1").and_return(app)
      get :show, :id => 1
      
      assigns[:application].should == app
    end
  end

  describe "#address" do
    context "without a query" do
      it "should not do a whole lot" do
        get :address
        response.should be_success
      end
    end

    context "with a query for a partially complete address" do
      before :each do
        location1 = mock(Location, :error => false, :full_address => "25 Govett Street, Katoomba NSW 2780",
          :lat => 1.0, :lng => 2.0)
        location2 = mock(Location, :full_address => "25 Govett Place, Weston Creek ACT 2611")
        location3 = mock(Location, :full_address => "25 Govett Street, Randwick NSW 2031")
        location1.stub!(:all).and_return([location1, location2, location3])
        Location.should_receive(:geocode).with("25 Govett").and_return(location1)
      end

      it "should set the normalised address" do
        get :address, :q => "25 Govett"
        assigns[:q].should == "25 Govett Street, Katoomba NSW 2780"
      end

      it "should set an alert based on the normalised address" do
        get :address, :q => "25 Govett"
        assigns[:alert].address.should == "25 Govett Street, Katoomba NSW 2780"
      end

      it "should set alternate addresses too" do
        get :address, :q => "25 Govett"
        assigns[:other_addresses].should == [
          "25 Govett Place, Weston Creek ACT 2611",
          "25 Govett Street, Randwick NSW 2031"]
      end

      it "should return nearby applications sorted by the date they were scraped" do
        a = mock
        result = mock
        Application.should_receive(:near).with([1.0, 2.0], 2.0, :units => :km).and_return(a)
        a.should_receive(:paginate).with(:page => nil, :per_page => 30).and_return(result)
        get :address, :q => "25 Govett"
        assigns[:applications].should == result
      end

      it "should return nearby applications sorted by distance" do
        a = mock
        b = mock
        result = mock
        Application.should_receive(:near).with([1.0, 2.0], 2.0, :units => :km).and_return(a)
        a.should_receive(:reorder).with("distance").and_return(b)
        b.should_receive(:paginate).with(:page => nil, :per_page => 30).and_return(result)
        get :address, :q => "25 Govett", :sort => "distance"
        assigns[:applications].should == result
      end
    end
  end
end
