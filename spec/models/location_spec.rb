require File.dirname(__FILE__) + '/../spec_helper'

describe "Location" do
  describe "valid location" do
    before :each do
      @result = double(all: [double(country_code: "AU", lat: -33.772609, lng: 150.624263, accuracy: 6)])
      Geokit::Geocoders::GoogleGeocoder3.should_receive(:geocode).with("24 Bruce Road, Glenbrook, NSW 2773", bias: "au").and_return(@result)
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
    Geokit::Geocoders::GoogleGeocoder3.should_receive(:geocode).with("", bias: "au").and_return(double(lat: nil, lng: nil, all: []))
    l = Location.geocode("")
    l.lat.should be_nil
    l.lng.should be_nil
  end

  # Hmm... this test really needs a network connection to run and doesn't really make sense to test
  # through doubleing. So, commenting out
  #it "should return the country code of the geocoded address" do
  #  Location.geocode("24 Bruce Road, Glenbrook, NSW 2773").country_code.should == "AU"
  #end

  # Same as the test above
  #it "should bias the results of geocoding to australian addresses" do
  #  Location.geocode("Bruce Road").country_code.should == "AU"
  #end

  it "should normalise addresses without the country in them" do
    loc = Location.new(double(full_address: "24 Bruce Road, Glenbrook, NSW 2773, Australia"))
    loc.full_address.should == "24 Bruce Road, Glenbrook, NSW 2773"
  end

  it "should error if the address is empty" do
    Geokit::Geocoders::GoogleGeocoder3.stub(:geocode).and_return(double(all: []))

    l = Location.geocode("")
    l.error.should == "Please enter a street address"
  end

  it "should error if the address is not valid" do
    Geokit::Geocoders::GoogleGeocoder3.stub(:geocode).and_return(double(lat: nil, lng: nil, all: []))

    l = Location.geocode("rxsd23dfj")
    l.error.should == "Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’"
  end

  it "should error if the street address is not in australia" do
    Geokit::Geocoders::GoogleGeocoder3.stub(:geocode).and_return(double(lat: 1, lng: 2, country_code: "US", all: [double(lat: 1, lng: 2, country_code: "US")]))

    l = Location.geocode("New York")
    l.error.should == "Unfortunately we only cover Australia. It looks like that address is in another country."
  end

  it "should not error if there are multiple matches from the geocoder" do
    Geokit::Geocoders::GoogleGeocoder3.stub(:geocode).and_return(double(all:
      [double(country_code: "AU", lat: 1, lng: 2, accuracy: 6), double(country_code: "AU", lat: 1.1, lng: 2.1, accuracy: 6)]))

    l = Location.geocode("Bruce Road")
    l.error.should be_nil
  end

  it "should error if the address is not a full street address, street address or suburb but rather place vaguer than a suburb" do
    Geokit::Geocoders::GoogleGeocoder3.stub(:geocode).and_return(double(all: [double(country_code: "AU", lat: 1, lng: 2, accuracy: 3, full_address: "Glenbrook NSW, Australia")]))

    l = Location.geocode("New South Wales")
    l.error.should == "Please enter a more detailed address like ‘Sowerby St, Goulburn, NSW’"
  end

  it "should list potential matches and they should be in Australia" do
    m = double(full_address: "Bathurst Rd, Orange NSW 2800, Australia", country_code: "AU")
    all = [
      m,
      double(full_address: "Bathurst Rd, Katoomba NSW 2780, Australia", country_code: "AU"),
      double(full_address: "Bathurst Rd, Staplehurst, Kent TN12 0, UK", country_code: "UK"),
      double(full_address: "Bathurst Rd, Cape Town 7708, South Africa", country_code: "ZA"),
      double(full_address: "Bathurst Rd, Winnersh, Wokingham RG41 5, UK", country_code: "UK"),
      double(full_address: "Bathurst Rd, Catonsville, MD 21228, USA", country_code: "US"),
      double(full_address: "Bathurst Rd, Durban South 4004, South Africa", country_code: "ZA"),
      double(full_address: "Bathurst Rd, Port Kennedy WA 6172, Australia", country_code: "AU"),
      double(full_address: "Bathurst Rd, Campbell River, BC V9W, Canada", country_code: "CA"),
      double(full_address: "Bathurst Rd, Riverside, CA, USA", country_code: "US"),
    ]
    m.stub(all: all)
    Geokit::Geocoders::GoogleGeocoder3.stub(:geocode).and_return(double(all: all))
    l = Location.geocode("Bathurst Rd")
    all = l.all
    all.count.should == 3
    all[0].full_address.should == "Bathurst Rd, Orange NSW 2800"
    all[1].full_address.should == "Bathurst Rd, Katoomba NSW 2780"
    all[2].full_address.should == "Bathurst Rd, Port Kennedy WA 6172"
  end

  it "the first match should only return addresses in Australia" do
    m = double(full_address: "Sowerby St, Garfield NSW 2580, Australia", country_code: "AU")
    all = [
      double(full_address: "Sowerby St, Lawrence 9532, New Zealand", country_code: "NZ"),
      m,
      double(full_address: "Sowerby St, Sowerby, Halifax, Calderdale HX6 3, UK", country_code: "UK"),
      double(full_address: "Sowerby St, Burnley, Lancashire BB12 8, UK", country_code: "UK")
    ]
    m.stub(all: all)
    Geokit::Geocoders::GoogleGeocoder3.stub(:geocode).and_return(double(full_address: "Sowerby St, Lawrence 9532, New Zealand", all: all))
    l = Location.geocode("Sowerby St")
    l.full_address.should == "Sowerby St, Garfield NSW 2580"
    all = l.all
    all.count.should == 1
    all[0].full_address.should == "Sowerby St, Garfield NSW 2580"
  end
end
