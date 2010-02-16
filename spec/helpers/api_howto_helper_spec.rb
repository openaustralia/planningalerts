require 'spec_helper'

describe ApiHowtoHelper do
  it "should return the url for mapping arbitrary georss feed on Google maps" do
    helper.mapify("http://foo.com", 4).should == "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=4&om=1&q=http%3A%2F%2Ffoo.com"
  end
  
  it "should provide urls of examples of use of the api" do
    helper.api_example_address_url.should == "http://test.host/api?call=address&address=24+Bruce+Road+Glenbrook%2C+NSW+2773&area_size=4000"
    helper.api_example_latlong_url.should == "http://test.host/api?call=point&lat=-33.772609&lng=150.624263&area_size=4000"
    helper.api_example_area_url.should == "http://test.host/api?call=area&bottom_left_lat=-38.556757&bottom_left_lng=140.83374&top_right_lat=-29.113775&top_right_lng=153.325195"
    helper.api_example_authority_url.should == "http://test.host/api?call=authority&authority=Blue+Mountains"
  end
  
  it "should display the example urls nicely" do
    helper.api_example_address_url_html.should == "http://test.host/api?<strong>call</strong>=address&<strong>address</strong>=[address]&<strong>area_size</strong>=[size_in_metres]"
    helper.api_example_latlong_url_html.should == "http://test.host/api?<strong>call</strong>=point&<strong>lat</strong>=[latitude]&<strong>lng</strong>=[longitude]&<strong>area_size</strong>=[size_in_metres]"
    helper.api_example_area_url_html.should == "http://test.host/api?<strong>call</strong>=area&<strong>bottom_left_lat</strong>=[latitude]&<strong>bottom_left_lng</strong>=[longitude]&<strong>top_right_lat</strong>=[latitude]&<strong>top_right_lng</strong>=[longitude]"
    helper.api_example_authority_url_html.should == "http://test.host/api?<strong>call</strong>=authority&<strong>authority</strong>=[name]"
  end
end
