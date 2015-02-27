require 'spec_helper'

describe ApiHowtoHelper do
  it "should return the url for mapping arbitrary georss feed on Google maps" do
    helper.mapify("http://foo.com", 4).should == "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=4&om=1&q=http%3A%2F%2Ffoo.com"
  end

  it "should provide urls of examples of use of the api" do
    helper.api_example_address_url("js", nil).should == "http://api.planningalerts.org.au/applications.js?address=24+Bruce+Road+Glenbrook%2C+NSW+2773&radius=4000"
    helper.api_example_latlong_url("js", nil).should == "http://api.planningalerts.org.au/applications.js?lat=-33.772609&lng=150.624263&radius=4000"
    helper.api_example_area_url("js", nil).should == "http://api.planningalerts.org.au/applications.js?bottom_left_lat=-38.556757&bottom_left_lng=140.83374&top_right_lat=-29.113775&top_right_lng=153.325195"
    helper.api_example_authority_url("js", nil).should == "http://api.planningalerts.org.au/authorities/blue_mountains/applications.js"
    helper.api_example_postcode_url("js", nil).should == "http://api.planningalerts.org.au/applications.js?postcode=2780"
    helper.api_example_suburb_and_state_url("js", nil).should == "http://api.planningalerts.org.au/applications.js?state=NSW&suburb=Katoomba"
  end

  it "should display the example urls nicely" do
    helper.api_example_address_url_html("rss", nil).should == "http://api.planningalerts.org.au/applications.rss?<strong>address</strong>=[address]&amp;<strong>key</strong>=[key]&amp;<strong>radius</strong>=[distance_in_metres]"
    helper.api_example_latlong_url_html("rss", nil).should == "http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=[key]&amp;<strong>lat</strong>=[latitude]&amp;<strong>lng</strong>=[longitude]&amp;<strong>radius</strong>=[distance_in_metres]"
    helper.api_example_area_url_html("rss", nil).should == "http://api.planningalerts.org.au/applications.rss?<strong>bottom_left_lat</strong>=[latitude]&amp;<strong>bottom_left_lng</strong>=[longitude]&amp;<strong>key</strong>=[key]&amp;<strong>top_right_lat</strong>=[latitude]&amp;<strong>top_right_lng</strong>=[longitude]"
    helper.api_example_authority_url_html("rss", nil).should == "http://api.planningalerts.org.au/authorities/[name]/applications.rss?<strong>key</strong>=[key]"
    helper.api_example_postcode_url_html("rss", nil).should == "http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=[key]&amp;<strong>postcode</strong>=[postcode]"
    helper.api_example_suburb_and_state_url_html("rss", nil).should == "http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=[key]&amp;<strong>state</strong>=[state]&amp;<strong>suburb</strong>=[suburb]"
  end

  it "should display the example urls nicely" do
    helper.api_example_address_url_html("rss", "123").should == "http://api.planningalerts.org.au/applications.rss?<strong>address</strong>=[address]&amp;<strong>key</strong>=123&amp;<strong>radius</strong>=[distance_in_metres]"
    helper.api_example_latlong_url_html("rss", "123").should == "http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=123&amp;<strong>lat</strong>=[latitude]&amp;<strong>lng</strong>=[longitude]&amp;<strong>radius</strong>=[distance_in_metres]"
    helper.api_example_area_url_html("rss", "123").should == "http://api.planningalerts.org.au/applications.rss?<strong>bottom_left_lat</strong>=[latitude]&amp;<strong>bottom_left_lng</strong>=[longitude]&amp;<strong>key</strong>=123&amp;<strong>top_right_lat</strong>=[latitude]&amp;<strong>top_right_lng</strong>=[longitude]"
    helper.api_example_authority_url_html("rss", "123").should == "http://api.planningalerts.org.au/authorities/[name]/applications.rss?<strong>key</strong>=123"
    helper.api_example_postcode_url_html("rss", "123").should == "http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=123&amp;<strong>postcode</strong>=[postcode]"
    helper.api_example_suburb_and_state_url_html("rss", "123").should == "http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=123&amp;<strong>state</strong>=[state]&amp;<strong>suburb</strong>=[suburb]"
  end
end
