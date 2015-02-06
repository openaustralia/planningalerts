require 'spec_helper'

describe ApplicationsController do
  before :each do
    request.env['HTTPS'] = 'on'
  end

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

    describe "error checking on parameters used" do
      it "should not do error checking on the normal html sites" do
        VCR.use_cassette('planningalerts') do
          get :index, :address => "24 Bruce Road Glenbrook", :radius => 4000, :foo => 200, :bar => "fiddle"
        end
        response.code.should == "200"
      end
    end

    describe "search by authority" do
      it "should give a 404 when an invalid authority_id is used" do
        Authority.should_receive(:find_by_short_name_encoded).with("this_authority_does_not_exist").and_return(nil)
        lambda{get :index, :authority_id => "this_authority_does_not_exist"}.should raise_error ActiveRecord::RecordNotFound
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
