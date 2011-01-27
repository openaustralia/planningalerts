require 'spec_helper'

describe ApiHowtoHelper do
  it "should return the url for mapping arbitrary georss feed on Google maps" do
    helper.mapify("http://foo.com", 4).should == "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=4&om=1&q=http%3A%2F%2Ffoo.com"
  end
  
  it "should provide urls of examples of use of the api" do
    helper.api_example_address_url.should == "http://test.host/applications.rss?address=24+Bruce+Road+Glenbrook%2C+NSW+2773&radius=4000"
    helper.api_example_latlong_url.should == "http://test.host/applications.rss?lat=-33.772609&lng=150.624263&radius=4000"
    helper.api_example_area_url.should == "http://test.host/applications.rss?bottom_left_lat=-38.556757&bottom_left_lng=140.83374&top_right_lat=-29.113775&top_right_lng=153.325195"
    helper.api_example_authority_url.should == "http://test.host/authorities/blue_mountains/applications.rss"
    helper.api_example_postcode_url.should == "http://test.host/applications.rss?postcode=2780"
    helper.api_example_suburb_and_state_url.should == "http://test.host/applications.rss?state=NSW&suburb=Katoomba"
  end
  
  it "should display the example urls nicely" do
    helper.api_example_address_url_html.should == "http://test.host/applications.rss?<strong>address</strong>=[address]&amp;<strong>radius</strong>=[distance_in_metres]"
    helper.api_example_latlong_url_html.should == "http://test.host/applications.rss?<strong>lat</strong>=[latitude]&amp;<strong>lng</strong>=[longitude]&amp;<strong>radius</strong>=[distance_in_metres]"
    helper.api_example_area_url_html.should == "http://test.host/applications.rss?<strong>bottom_left_lat</strong>=[latitude]&amp;<strong>bottom_left_lng</strong>=[longitude]&amp;<strong>top_right_lat</strong>=[latitude]&amp;<strong>top_right_lng</strong>=[longitude]"
    helper.api_example_authority_url_html.should == "http://test.host/authorities/[name]/applications.rss"
    helper.api_example_postcode_url_html.should == "http://test.host/applications.rss?<strong>postcode</strong>=[postcode]"
    helper.api_example_suburb_and_state_url_html.should == "http://test.host/applications.rss?<strong>state</strong>=[state]&amp;<strong>suburb</strong>=[suburb]"
  end
end
