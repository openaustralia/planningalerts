require File.dirname(__FILE__) + '/../spec_helper'

describe "Location" do
  it "should geocode an address into a latitude and longitude by using the Google service" do
    Geokit::Geocoders::GoogleGeocoder.should_receive(:geocode).with("24 Bruce Road, Glenbrook, NSW 2773", :bias => "au").and_return(
      Geokit::LatLng.new(-33.772609, 150.624263))
    loc = Location.geocode("24 Bruce Road, Glenbrook, NSW 2773")
    loc.lat.should == -33.772609
    loc.lng.should == 150.624263
  end
  
  it "should return nil if the address to geocode isn't valid" do
    Geokit::Geocoders::GoogleGeocoder.should_receive(:geocode).with("", :bias => "au").and_return(Geokit::LatLng.new(nil, nil))
    l = Location.geocode("")
    l.lat.should be_nil
    l.lng.should be_nil
  end

  # Hmm... this test really needs a network connection to run and doesn't really make sense to test
  # through mocking. So, commenting out
  #it "should return the country code of the geocoded address" do
  #  Location.geocode("24 Bruce Road, Glenbrook, NSW 2773").country_code.should == "AU"
  #end
  
  # Same as the test above
  #it "should bias the results of geocoding to australian addresses" do
  #  Location.geocode("Bruce Road").country_code.should == "AU"
  #end
  
  it "should normalise addresses without the country in them" do
    loc = Location.new(mock(:full_address => "24 Bruce Road, Glenbrook, NSW 2773, Australia"))
    loc.full_address.should == "24 Bruce Road, Glenbrook, NSW 2773"
  end
end