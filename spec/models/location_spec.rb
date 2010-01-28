require File.dirname(__FILE__) + '/../spec_helper'

describe "Location" do
  # This test requires an internet connection - should get rid of this once I'm a little bit more confident of Geokit's use
  it "should geocode an address into a latitude and longitude" do
    Geokit::Geocoders::GoogleGeocoder.geocode("24 Bruce Road, Glenbrook, NSW 2773").should ==
      Geokit::LatLng.new(-33.772609, 150.624263)
  end
end