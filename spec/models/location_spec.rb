require File.dirname(__FILE__) + '/../spec_helper'

describe "Location" do
  it "should geocode an address into a latitude and longitude by using the Google service" do
    Geokit::Geocoders::GoogleGeocoder.should_receive(:geocode).with("24 Bruce Road, Glenbrook, NSW 2773").and_return(
      Geokit::LatLng.new(-33.772609, 150.624263))
    Location.geocode("24 Bruce Road, Glenbrook, NSW 2773").should == Location.new(-33.772609, 150.624263)
  end
end