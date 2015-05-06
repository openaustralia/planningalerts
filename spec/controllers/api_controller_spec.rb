require 'spec_helper'

describe ApiController do
  describe "#all" do
    describe "rss" do
      it "should not support rss" do
        user = User.create!(email: "foo@bar.com", password: "foofoo")
        get :all, :format => "rss", :key => user.api_key
        response.status.should == 406
      end
    end

    describe "json" do
      it "should not find recent applications if no api key is given" do
        VCR.use_cassette('planningalerts') do
          result = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
          Application.stub_chain(:where, :paginate).and_return([result])
        end
        get :all, :format => "js"
        response.status.should == 401
        response.body.should == '{"error":"not authorised"}'
      end

      it "should error if invalid api key is given" do
        VCR.use_cassette('planningalerts') do
          result = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
          Application.stub_chain(:where, :paginate).and_return([result])
        end
        get :all, :key => "jsdfhsd", :format => "js"
        response.status.should == 401
        response.body.should == '{"error":"not authorised"}'
      end

      it "should error if valid api key is given but no bulk api access" do
        user = User.create!(email: "foo@bar.com", password: "foofoo")
        VCR.use_cassette('planningalerts') do
          result = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
          Application.stub_chain(:where, :paginate).and_return([result])
        end
        get :all, :key => user.api_key, :format => "js"
        response.status.should == 401
        response.body.should == '{"error":"not authorised"}'
      end

      it "should find recent applications if api key is given" do
        user = User.create!(email: "foo@bar.com", password: "foofoo")
        user.update_attribute(:bulk_api, true)
        VCR.use_cassette('planningalerts') do
          result = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
          Application.stub_chain(:where, :paginate).and_return([result])
        end
        get :all, :key => user.api_key, :format => "js"
        response.status.should == 200
        JSON.parse(response.body).should == {
          "application_count" => 1,
          "max_id" => 10,
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
  end

  describe "#postcode" do
    it "should find recent applications for a postcode" do
      result, scope = mock, mock
      Application.should_receive(:where).with(:postcode => "2780").and_return(scope)
      scope.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)
      get :postcode, :format => "rss", :postcode => "2780"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in postcode 2780"
    end

    it "should support jsonp" do
      VCR.use_cassette('planningalerts') do
        result = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
        Application.stub_chain(:where, :paginate).and_return([result])
      end
      get :postcode, :format => "js", :postcode => "2780", :callback => "foobar"
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

    it "should support json api version 2" do
      VCR.use_cassette('planningalerts') do
        application = Factory(:application, :id => 10, :date_scraped => Time.utc(2001,1,1))
        result = [application]
        result.stub!(:total_pages).and_return(5)
        Application.stub_chain(:where, :paginate).and_return(result)
      end
      get :postcode, :format => "js", :v => "2", :postcode => "2780"
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

  describe "#point" do
    describe "failed search by address" do
      it "should error if some unknown parameters are included" do
        get :point, :format => "rss", :address => "24 Bruce Road Glenbrook", :radius => 4000, :foo => 200, :bar => "fiddle"
        response.body.should == "Bad request: Invalid parameter(s) used: bar, foo"
        response.code.should == "400"
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
        get :point, :format => "rss", :address => "24 Bruce Road Glenbrook", :radius => 4000
        assigns[:applications].should == @result
        # Should use the normalised form of the address in the description
        assigns[:description].should == "Recent applications within 4 km of 24 Bruce Road, Glenbrook NSW 2773"
      end

      it "should find recent applications near the address using the old parameter name" do
        get :point, :format => "rss", :address => "24 Bruce Road Glenbrook", :area_size => 4000
        assigns[:applications].should == @result
        assigns[:description].should == "Recent applications within 4 km of 24 Bruce Road, Glenbrook NSW 2773"
      end

      it "should log the api call" do
       get :point, :format => "rss", :address => "24 Bruce Road Glenbrook", :radius => 4000
       a = ApiStatistic.first
       a.ip_address.should == "0.0.0.0"
       a.query.should == "/applications.rss?address=24+Bruce+Road+Glenbrook&radius=4000"
      end

      it "should use a search radius of 2000 when none is specified" do
        result = mock
        Application.stub_chain(:near, :paginate).and_return(result)

        get :point, :address => "24 Bruce Road Glenbrook", :format => "rss"
        assigns[:applications].should == result
        assigns[:description].should == "Recent applications within 2 km of 24 Bruce Road, Glenbrook NSW 2773"
      end
    end

    describe "search by lat & lng" do
      before :each do
        @result = mock

        Application.stub_chain(:near, :paginate).and_return(@result)
      end

      it "should find recent applications near the point" do
        get :point, :format => "rss", :lat => 1.0, :lng => 2.0, :radius => 4000
        assigns[:applications].should == @result
        assigns[:description].should == "Recent applications within 4 km of 1.0,2.0"
      end

      it "should find recent applications near the point using the old parameter name" do
        get :point, :format => "rss", :lat => 1.0, :lng => 2.0, :area_size => 4000
        assigns[:applications].should == @result
        assigns[:description].should == "Recent applications within 4 km of 1.0,2.0"
      end
    end
  end

  describe "#area" do
    it "should find recent applications in an area" do
      result, scope = mock, mock
      Application.should_receive(:where).with("lat > ? AND lng > ? AND lat < ? AND lng < ?", 1.0, 2.0, 3.0, 4.0).and_return(scope)
      scope.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)

      get :area, :format => "rss", :bottom_left_lat => 1.0, :bottom_left_lng => 2.0,
        :top_right_lat => 3.0, :top_right_lng => 4.0
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in the area (1.0,2.0) (3.0,4.0)"
    end
  end

  describe "#authority" do
    it "should find recent applications for an authority" do
      authority, result, scope = mock, mock, mock

      Authority.should_receive(:find_by_short_name_encoded).with("blue_mountains").and_return(authority)
      authority.should_receive(:applications).and_return(scope)
      scope.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)
      authority.should_receive(:full_name_and_state).and_return("Blue Mountains City Council")

      get :authority, :format => "rss", :authority_id => "blue_mountains"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications from Blue Mountains City Council"
    end
  end

  describe "#suburb" do
    it "should find recent applications for a suburb" do
      result, scope = mock, mock
      Application.should_receive(:where).with(:suburb => "Katoomba").and_return(scope)
      scope.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)
      get :suburb, :format => "rss", :suburb => "Katoomba"
      assigns[:applications].should == result
      assigns[:description].should == "Recent applications in Katoomba"
    end

    describe "search by suburb and state" do
      it "should find recent applications for a suburb and state" do
        result, scope1, scope2 = mock, mock, mock
        Application.should_receive(:where).with(:suburb => "Katoomba").and_return(scope1)
        scope1.should_receive(:where).with(:state => "NSW").and_return(scope2)
        scope2.should_receive(:paginate).with(:page => nil, :per_page => 100).and_return(result)
        get :suburb, :format => "rss", :suburb => "Katoomba", :state => "NSW"
        assigns[:applications].should == result
        assigns[:description].should == "Recent applications in Katoomba, NSW"
      end
    end
  end

  describe "#date_scraped" do
    context "invalid authentication" do
      it "should error if invalid api key is given" do
        get :date_scraped, :key => "jsdfhsd", :format => "js", date_scraped: Date.today
        response.status.should == 401
        response.body.should == '{"error":"not authorised"}'
      end

      it "should error if valid api key is given but no bulk api access" do
        user = User.create!(email: "foo@bar.com", password: "foofoo")
        get :date_scraped, :key => user.api_key, :format => "js", date_scraped: Date.today
        response.status.should == 401
        response.body.should == '{"error":"not authorised"}'
      end
    end

    context "valid authentication" do
      let(:user) { FactoryGirl.create(:user, bulk_api: true) }

      it "should be successful if valid api key is given with bulk api access" do
        get :date_scraped, :key => user.api_key, :format => "js", date_scraped: Date.today
        response.should be_success
      end
    end
  end
end
