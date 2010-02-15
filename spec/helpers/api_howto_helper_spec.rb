require 'spec_helper'

describe ApiHowtoHelper do
  it "should return the url for mapping arbitrary georss feed on Google maps" do
    helper.mapify("http://foo.com", 4).should == "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=4&om=1&q=http%3A%2F%2Ffoo.com"
  end
  
  it "should provide urls of examples of use of the api" do
    helper.api_example_address_url.should == "http://test.host/api.php?call=address&address=24+Bruce+Road+Glenbrook%2C+NSW+2773&area_size=4000"
    helper.api_example_latlong_url.should == "http://test.host/api.php?call=point&lat=-33.772609&lng=150.624263&area_size=4000"
    helper.api_example_area_url.should == "http://test.host/api.php?call=area&bottom_left_lat=-38.556757&bottom_left_lng=140.83374&top_right_lat=-29.113775&top_right_lng=153.325195"
    helper.api_example_authority_url.should == "http://test.host/api.php?call=authority&authority=Blue+Mountains"
  end
end
