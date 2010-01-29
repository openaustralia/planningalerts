require File.dirname(__FILE__) + '/../spec_helper'

describe "Location" do
  it "should geocode an address into a latitude and longitude by using the Google service" do
    Geokit::Geocoders::GoogleGeocoder.should_receive(:geocode).with("24 Bruce Road, Glenbrook, NSW 2773").and_return(
      Geokit::LatLng.new(-33.772609, 150.624263))
    Location.geocode("24 Bruce Road, Glenbrook, NSW 2773").should == Location.new(-33.772609, 150.624263)
  end
  
  it "should calculate the coordinates of a square box on the surface of the earth centred on the first point" do
    Location.new(-33.772609, 150.624263).box_with_size_in_metres(200).should ==
      [Location.new(-33.773508234721, 150.62309060152), Location.new(-33.771709765279, 150.62543539848)]
  end
end