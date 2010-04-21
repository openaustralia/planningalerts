require 'spec_helper'

describe ApplicationsController do
  describe "show" do
    before :each do
      authority = mock_model(Authority, :full_name => "An authority", :short_name => "Blue Mountains")
      assigns[:application] = mock_model(Application, :location => Location.new(1.0, 2.0), :lat => 1.0, :lng => 2.0, :address => "foo", :map_url => "http://a.map.url",
        :description => "A planning application", :council_reference => "A1", :authority => authority, :info_url => "http://info.url", :comment_url => "http://comment.url")
      assigns[:nearby_applications] = []
    end
    
    it "should say when the application was received by the planning authority and when it appeared on PlanningAlerts" do
      assigns[:application].stub!(:date_received).and_return(20.days.ago)
      assigns[:application].stub!(:date_scraped).and_return(18.days.ago)
      render "applications/show"
      response.should have_tag("p.dates", "We found this application for you on the planning authority's website 18 days ago.\n    It was received by them 2 days earlier.")
    end
  
    it "should say something appropriate when the received date is not known" do
      assigns[:application].stub!(:date_received).and_return(nil)
      assigns[:application].stub!(:date_scraped).and_return(18.days.ago)
      render "applications/show"
      response.should have_tag("p.dates", "We found this application for you on the planning authority's website 18 days ago.\n    The date it was received by them was not recorded.")
    end
  end
  
  describe "show with application with no location" do
    it "should not display the map" do
      authority = mock_model(Authority, :full_name => "An authority", :short_name => "Blue Mountains")
      assigns[:application] = mock_model(Application, :location => nil, :lat => nil, :lng => nil, :address => "An address that can't be geocoded", :map_url => "http://a.map.url",
        :description => "A planning application", :council_reference => "A1", :date_scraped => Time.now, :date_received => nil, :authority => authority, :info_url => "http://info.url",
        :comment_url => "http://comment.url")
      assigns[:nearby_applications] = []
      render "applications/show"
      response.should_not have_tag("div#map_div")
    end
  end
end