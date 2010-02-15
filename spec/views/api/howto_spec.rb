require 'spec_helper'

describe ApiController do
  before :each do
    render "api/howto"
  end
  
  it "should contain urls for call=address example" do
    response.should have_tag('div.apiitem code',      "http://test.host/api.php?call=address&address=[some address]&area_size=[size in metres]")
    # TODO: We really shouldn't have those "&" being substituted with "&amp;"
    response.should have_tag('div.apiitem a[href=?]', "http://test.host/api.php?call=address&amp;address=24+Bruce+Road+Glenbrook%2C+NSW+2773&amp;area_size=4000", "view example")
  end

  it "should contain urls for call=point example" do
    response.should have_tag('div.apiitem:nth-of-type(2) code',      "http://test.host/api.php?call=point&lat=[some latitude]&lng=[some longitude]&area_size=[size in metres]")    
    response.should have_tag('div.apiitem:nth-of-type(2) a[href=?]', "http://test.host/api.php?call=point&amp;lat=-33.772609&amp;lng=150.624263&amp;area_size=4000", "view example")
  end

  it "should contain urls for call=area example" do
    response.should have_tag('div.apiitem:nth-of-type(3) code',      "http://test.host/api.php?call=area&bottom_left_lat=[some latitude]&bottom_left_lng=[some longitude]&top_right_lat=[some latitude]&top_right_lng=[some longitude]")    
    response.should have_tag('div.apiitem:nth-of-type(3) a[href=?]', "http://test.host/api.php?call=area&amp;bottom_left_lat=-38.556757&amp;bottom_left_lng=140.83374&amp;top_right_lat=-29.113775&amp;top_right_lng=153.325195", "view example")
  end

  it "should contain urls for call=authority example" do
    response.should have_tag('div.apiitem:nth-of-type(4) code',      "http://test.host/api.php?call=authority&authority=[some name]")    
    response.should have_tag('div.apiitem:nth-of-type(4) a[href=?]', "http://test.host/api.php?call=authority&amp;authority=Blue+Mountains", "view example")
  end
end
