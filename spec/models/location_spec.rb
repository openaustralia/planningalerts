require File.dirname(__FILE__) + '/../spec_helper'

describe "Location" do
  describe "valid location" do
    before :each do
      @result = mock(:lat => -33.772609, :lng => 150.624263, :country_code => "AU", :all => [mock(:country_code => "AU")],
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
  
  it "should not error if there are multiple matches from the geocoder" do
    Geokit::Geocoders::GoogleGeocoder.stub!(:geocode).and_return(mock(:lat => 1, :lng => 2, :country_code => "AU",
      :all => [mock(:country_code => "AU"), mock(:country_code => "AU")], :full_address => "Bruce Rd, VIC 3885, Australia", :accuracy => 6))

    l = Location.geocode("Bruce Road")
    l.error.should be_nil
  end
  
  it "should error if the address is not a full street address but rather a suburb name or similar" do
    Geokit::Geocoders::GoogleGeocoder.stub!(:geocode).and_return(mock(:lat => 1, :lng => 2, :country_code => "AU",
      :all => [mock(:country_code => "AU")], :full_address => "Glenbrook NSW, Australia", :accuracy => 5))

    l = Location.geocode("Glenbrook, NSW")
    l.error.should == "isn't complete. We saw that address as \"Glenbrook NSW\" which we don't recognise as a full street address. Check your spelling and make sure to include suburb and state"
  end
  
  it "should list potential matches and they should be in Australia" do
    all = [
      mock(:full_address => "Bathurst Rd, Orange NSW 2800, Australia", :country_code => "AU"),
      mock(:full_address => "Bathurst Rd, Katoomba NSW 2780, Australia", :country_code => "AU"),
      mock(:full_address => "Bathurst Rd, Staplehurst, Kent TN12 0, UK", :country_code => "UK"),
      mock(:full_address => "Bathurst Rd, Cape Town 7708, South Africa", :country_code => "ZA"),
      mock(:full_address => "Bathurst Rd, Winnersh, Wokingham RG41 5, UK", :country_code => "UK"),
      mock(:full_address => "Bathurst Rd, Catonsville, MD 21228, USA", :country_code => "US"),
      mock(:full_address => "Bathurst Rd, Durban South 4004, South Africa", :country_code => "ZA"),
      mock(:full_address => "Bathurst Rd, Port Kennedy WA 6172, Australia", :country_code => "AU"),
      mock(:full_address => "Bathurst Rd, Campbell River, BC V9W, Canada", :country_code => "CA"),
      mock(:full_address => "Bathurst Rd, Riverside, CA, USA", :country_code => "US"),
    ]
    Geokit::Geocoders::GoogleGeocoder.stub!(:geocode).and_return(mock(:all => all))
    l = Location.geocode("Bathurst Rd")
    all = l.all
    all.count.should == 3
    all[0].full_address.should == "Bathurst Rd, Orange NSW 2800"
    all[1].full_address.should == "Bathurst Rd, Katoomba NSW 2780"
    all[2].full_address.should == "Bathurst Rd, Port Kennedy WA 6172"
  end
end