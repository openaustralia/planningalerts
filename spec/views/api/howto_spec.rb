require 'spec_helper'

describe ApiController do
  before :each do
    assigns[:api_example_address_url] = "http://test.host/api.php?call=address&address=24+Bruce+Road+Glenbrook%2C+NSW+2773&area_size=4000"
    assigns[:api_example_latlong_url] = "http://test.host/api.php?call=point&lat=1.0&lng=2.0&area_size=4000"
    assigns[:api_example_area_url] = "http://test.host/api.php?call=area&bottom_left_lat=1.0&bottom_left_lng=2.0&top_right_lat=3.0&top_right_lng=4.0"
    assigns[:api_example_authority_url] = "http://test.host/api.php?call=authority&authority=Blue+Mountains"
    assigns[:api_url] = "http://test.host/api.php"

    render "api/howto"
  end
  
  it "should contain urls for call=address example" do
    response.should have_tag('div.apiitem code',      "http://test.host/api.php?call=address&address=[some address]&area_size=[size in metres]")
    # TODO: We really shouldn't have those "&" being substituted with "&amp;"
    response.should have_tag('div.apiitem a[href=?]', "http://test.host/api.php?call=address&amp;address=24+Bruce+Road+Glenbrook%2C+NSW+2773&amp;area_size=4000", "view example")
  end

  it "should contain urls for call=point example" do
    response.should have_tag('div.apiitem:nth-of-type(2) code',      "http://test.host/api.php?call=point&lat=[some latitude]&lng=[some longitude]&area_size=[size in metres]")    
    response.should have_tag('div.apiitem:nth-of-type(2) a[href=?]', "http://test.host/api.php?call=point&amp;lat=1.0&amp;lng=2.0&amp;area_size=4000", "view example")
  end

  it "should contain urls for call=area example" do
    response.should have_tag('div.apiitem:nth-of-type(3) code',      "http://test.host/api.php?call=area&bottom_left_lat=[some latitude]&bottom_left_lng=[some longitude]&top_right_lat=[some latitude]&top_right_lng=[some longitude]")    
    response.should have_tag('div.apiitem:nth-of-type(3) a[href=?]', "http://test.host/api.php?call=area&amp;bottom_left_lat=1.0&amp;bottom_left_lng=2.0&amp;top_right_lat=3.0&amp;top_right_lng=4.0", "view example")
  end

  it "should contain urls for call=authority example" do
    response.should have_tag('div.apiitem:nth-of-type(4) code',      "http://test.host/api.php?call=authority&authority=[some name]")    
    response.should have_tag('div.apiitem:nth-of-type(4) a[href=?]', "http://test.host/api.php?call=authority&amp;authority=Blue+Mountains", "view example")
  end
end
