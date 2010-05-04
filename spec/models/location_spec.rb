require File.dirname(__FILE__) + '/../spec_helper'

describe "Location" do
  describe "valid location" do
    before :each do
      @result = mock(:lat => -33.772609, :lng => 150.624263, :country_code => "AU", :all => mock(:size => 1),
        :accuracy => 6)
      Geokit::Geocoders::GoogleGeocoder.should_receive(:geocode).with("24 Bruce Road, Glenbrook, NSW 2773", :bias => "au").and_return(@result)
      @loc = Location.geocode("24 Bruce Road, Glenbrook, NSW 2773")
    end

    it "should geocode an address into a latitude and longitude by using the Google service" do
      @loc.lat.should == -33.772609
      @loc.lng.should == 150.624263
    end
    
    it "should not error" do
      @loc.error.should be_nil
    end
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
  
  it "should error if the address is empty" do
    Geokit::Geocoders::GoogleGeocoder.stub!(:geocode).and_return(mock)

    l = Location.geocode("")
    l.error.should == "can't be empty"
  end
  
  it "should error if the address is not valid" do
    Geokit::Geocoders::GoogleGeocoder.stub!(:geocode).and_return(mock(:lat => nil, :lng => nil))

    l = Location.geocode("rxsd23dfj")
    l.error.should == "isn't valid"
  end
  
  it "should error if the street address is not in australia" do
    Geokit::Geocoders::GoogleGeocoder.stub!(:geocode).and_return(mock(:lat => 1, :lng => 2, :country_code => "US"))

    l = Location.geocode("New York")
    l.error.should == "isn't in Australia"
  end
  
  it "should error if there are multiple matches from the geocoder" do
    Geokit::Geocoders::GoogleGeocoder.stub!(:geocode).and_return(mock(:lat => 1, :lng => 2, :country_code => "AU",
      :all => mock(:size => 2), :full_address => "Bruce Rd, VIC 3885, Australia"))

    l = Location.geocode("Bruce Road")
    l.error.should == "isn't complete. Please enter a full street address, including suburb and state, e.g. Bruce Rd, VIC 3885"
  end
  
  it "should error if the address is not a full street address but rather a suburb name or similar" do
    Geokit::Geocoders::GoogleGeocoder.stub!(:geocode).and_return(mock(:lat => 1, :lng => 2, :country_code => "AU",
      :all => mock(:size => 1), :full_address => "Glenbrook NSW, Australia", :accuracy => 5))

    l = Location.geocode("Glenbrook, NSW")
    l.error.should == "isn't complete. We saw that address as \"Glenbrook NSW\" which we don't recognise as a full street address. Check your spelling and make sure to include suburb and state"
  end
end