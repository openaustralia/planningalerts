require 'spec_helper'

describe ApplicationsController do
  before :each do
    authority = mock_model(Authority, :full_name => "An authority", :short_name => "Blue Mountains")
    assigns[:application] = mock_model(Application, :map_url => "http://a.map.url",
      :description => "A planning application", :council_reference => "A1", :authority => authority, :info_url => "http://info.url", :comment_url => "http://comment.url",
      :on_notice_from => nil, :on_notice_to => nil, :find_all_nearest_or_recent => [])
  end
  
  describe "show" do
    before :each do
      assigns[:application].stub!(:address).and_return("foo")
      assigns[:application].stub!(:lat).and_return(1.0)
      assigns[:application].stub!(:lng).and_return(2.0)
      assigns[:application].stub!(:location).and_return(Location.new(1.0, 2.0))
    end
    
    it "should display the map" do
      assigns[:application].stub!(:date_received).and_return(nil)
      assigns[:application].stub!(:date_scraped).and_return(Time.now)
      render "applications/show"
      response.should have_tag("div#map_div")      
    end
    
    it "should say nothing about notice period when there is no information" do
      assigns[:application].stub!(:date_received).and_return(nil)
      assigns[:application].stub!(:date_scraped).and_return(Time.now)
      assigns[:application].stub!(:on_notice_from).and_return(nil)
      assigns[:application].stub!(:on_notice_to).and_return(nil)
      render "applications/show"
      response.should_not have_tag("p.on_notice")
    end
  end
  
  describe "show with application with no location" do
    it "should not display the map" do
      assigns[:application].stub!(:address).and_return("An address that can't be geocoded")
      assigns[:application].stub!(:lat).and_return(nil)
      assigns[:application].stub!(:lng).and_return(nil)
      assigns[:application].stub!(:location).and_return(nil)
      assigns[:application].stub!(:date_received).and_return(nil)
      assigns[:application].stub!(:date_scraped).and_return(Time.now)
        
      render "applications/show"
      response.should_not have_tag("div#map_div")
    end
  end
end