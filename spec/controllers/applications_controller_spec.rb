require 'spec_helper'

describe ApplicationsController do
  describe "#index" do
    describe "rss feed" do
      before :each do
        Location.stub!(:geocode).and_return(mock(:lat => 1.0, :lng => 2.0, :full_address => "24 Bruce Road, Glenbrook NSW 2773"))
      end

      it "should not provide a link for all applications" do
        get :index
        assigns[:rss].should be_nil
      end
    end

    it "should not find recent applications if no api key is given" do
      result = mock
      Application.stub_chain(:where, :paginate).and_return(result)
      get :api, :format => "rss"
      response.status.should == 401
      response.body.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <error>not authorised</error>\n</hash>\n"
    end

    it "should not find recent applications if invalid api key is given" do
      result = mock
      Application.stub_chain(:where, :paginate).and_return(result)
      get :api, :format => "rss", :key => "foobar"
      response.status.should == 401
      response.body.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <error>not authorised</error>\n</hash>\n"
    end

    it "should find recent applications if api key is given" do
      key = ApiKey.create
      result = mock
      Application.stub_chain(:where, :paginate).and_return(result)
      get :api, :format => "rss", :key => key.key
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications within the last 2 months"
      response.status.should == 200
    end

    describe "json api" do
      it "should not find recent applications if no api key is given" do
        VCR.use_cassette('planningalerts') do
          result = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
          Application.stub_chain(:where, :paginate).and_return([result])
        end
        get :api, :format => "js"
        response.status.should == 401
        response.body.should == '{"error":"not authorised"}'
      end

      it "should error if invalid api key is given" do
        VCR.use_cassette('planningalerts') do
          result = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
          Application.stub_chain(:where, :paginate).and_return([result])
        end
        get :api, :key => "jsdfhsd", :format => "js"
        response.status.should == 401
        response.body.should == '{"error":"not authorised"}'
      end

      it "should find recent applications if api key is given" do
        key = ApiKey.create
        VCR.use_cassette('planningalerts') do
          result = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
          Application.stub_chain(:where, :paginate).and_return([result])
        end
        get :api, :key => key.key, :format => "js"
        response.status.should == 200
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
        get :api_postcode, :format => "js", :postcode => "2780", :callback => "foobar"
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
        key = ApiKey.create
        VCR.use_cassette('planningalerts') do
          application = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
          result = [application]
          result.stub!(:total_pages).and_return(5)
          Application.stub_chain(:where, :paginate).and_return(result)
        end
        get :api, :format => "js", :v => "2", :key => key.key
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
        get :api_address, :format => "rss", :address => "24 Bruce Road Glenbrook", :radius => 4000
        assigns[:applications].should == @result
        # Should use the normalised form of the address in the description
        assigns[:description].should == "Recent applications within 4 km of 24 Bruce Road, Glenbrook NSW 2773"
      end

      it "should find recent applications near the address using the old parameter name" do
        get :api_address, :format => "rss", :address => "24 Bruce Road Glenbrook", :area_size => 4000
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
        get :api, :format => "rss", :address => "24 Bruce Road Glenbrook", :radius => 4000, :foo => 200, :bar => "fiddle"
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

        get :api_address, :address => "24 Bruce Road Glenbrook", :format => "rss"
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
        get :api_address, :format => "rss", :lat => 1.0, :lng => 2.0, :radius => 4000
        assigns[:applications].should == @result
        assigns[:description].should == "Recent applications within 4 km of 1.0,2.0"
      end

      it "should find recent applications near the point using the old parameter name" do
        get :api_address, :format => "rss", :lat => 1.0, :lng => 2.0, :area_size => 4000
        assigns[:applications].should == @result
        assigns[:description].should == "Recent applications within 4 km of 1.0,2.0"
      end
    end

    describe "search by area" do
      it "should find recent applications in an area" do
        result, scope = mock, mock
        Application.should_receive(:where).with("lat > ? AND lng > ? AND lat < ? AND lng < ?", 1.0, 2.0, 3.0, 4.0).and_return(scope)
        scope.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)

        get :api_area, :format => "rss", :bottom_left_lat => 1.0, :bottom_left_lng => 2.0,
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

        get :api_authority, :format => "rss", :authority_id => "blue_mountains"
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
        get :api_postcode, :format => "rss", :postcode => "2780"
        assigns[:applications].should == result
        assigns[:description].should == "Recent applications in postcode 2780"
      end
    end

    describe "search by suburb" do
      it "should find recent applications for a suburb" do
        result, scope = mock, mock
        Application.should_receive(:where).with(:suburb => "Katoomba").and_return(scope)
        scope.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)
        get :api_suburb, :format => "rss", :suburb => "Katoomba"
        assigns[:applications].should == result
        assigns[:description].should == "Recent applications in Katoomba"
      end
    end

    describe "search by suburb and state" do
      it "should find recent applications for a suburb and state" do
        result, scope1, scope2 = mock, mock, mock
        Application.should_receive(:where).with(:suburb => "Katoomba").and_return(scope1)
        scope1.should_receive(:where).with(:state => "NSW").and_return(scope2)
        scope2.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)
        get :api_suburb, :format => "rss", :suburb => "Katoomba", :state => "NSW"
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
end
