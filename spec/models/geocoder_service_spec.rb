# frozen_string_literal: true

require File.dirname(__FILE__) + "/../spec_helper"

describe "GeocoderService" do
  describe "#distance_to" do
    it "should return results consistent with endpoint method" do
      loc1 = Location.new(lat: -33.772609, lng: 150.624263)
      # 500 metres NE
      loc2 = loc1.endpoint(45, 500)
      expect(loc1.distance_to(loc2)).to be_within(0.1).of(500)
    end

    it "should return a known distance" do
      loc1 = Location.new(lat: -33.772609, lng: 150.624263)
      loc2 = Location.new(lat: -33.772, lng: 150.624)
      expect(loc1.distance_to(loc2)).to be_within(0.1).of(72)
    end
  end

  describe "valid location" do
    before :each do
      @result = double(all: [double(country_code: "AU", lat: -33.772609, lng: 150.624263, accuracy: 6, city: "Glenbrook", state: "NSW", zip: "2773", full_address: "24 Bruce Road, Glenbrook, NSW 2773, Australia")])
      expect(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).with("24 Bruce Road, Glenbrook, NSW 2773", bias: "au").and_return(@result)
      @loc = GeocoderService.geocode("24 Bruce Road, Glenbrook, NSW 2773")
    end

    it "should geocode an address into a latitude and longitude by using the Google service" do
      expect(@loc.lat).to eq(-33.772609)
      expect(@loc.lng).to eq(150.624263)
    end

    it "should not error" do
      expect(@loc.error).to be_nil
    end
  end

  it "should return nil if the address to geocode isn't valid" do
    expect(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).with("", bias: "au").and_return(double(lat: nil, lng: nil, all: []))
    l = GeocoderService.geocode("")
    expect(l.lat).to be_nil
    expect(l.lng).to be_nil
  end

  # Hmm... this test really needs a network connection to run and doesn't really make sense to test
  # through doubleing. So, commenting out
  # it "should return the country code of the geocoded address" do
  #   GeocoderService.geocode("24 Bruce Road, Glenbrook, NSW 2773").country_code.should == "AU"
  # end

  # Same as the test above
  # it "should bias the results of geocoding to australian addresses" do
  #   GeocoderService.geocode("Bruce Road").country_code.should == "AU"
  # end

  it "should normalise addresses without the country in them" do
    loc = GeocoderService.new(double(full_address: "24 Bruce Road, Glenbrook, NSW 2773, Australia", lat: 1.0, lng: 2.0, city: "Glenbrook", state: "NSW", zip: "2773", country_code: "AU", accuracy: nil))
    expect(loc.full_address).to eq("24 Bruce Road, Glenbrook, NSW 2773")
  end

  it "should error if the address is empty" do
    allow(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).and_return(double(all: []))

    l = GeocoderService.geocode("")
    expect(l.error).to eq("Please enter a street address")
  end

  it "should error if the address is not valid" do
    allow(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).and_return(double(lat: nil, lng: nil, all: []))

    l = GeocoderService.geocode("rxsd23dfj")
    expect(l.error).to eq("Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’")
  end

  it "should error if the street address is not in australia" do
    allow(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).and_return(double(lat: 1, lng: 2, country_code: "US", city: "New York", state: "NY", zip: nil, full_address: "New York, NY", accuracy: nil, all: [double(lat: 1, lng: 2, country_code: "US", city: "New York", state: "NY", zip: nil, full_address: "New York, NY", accuracy: nil)]))

    l = GeocoderService.geocode("New York")
    expect(l.error).to eq("Unfortunately we only cover Australia. It looks like that address is in another country.")
  end

  it "should not error if there are multiple matches from the geocoder" do
    allow(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).and_return(double(all:
      [double(country_code: "AU", lat: 1, lng: 2, accuracy: 6, city: "Glenbrook", state: "NSW", zip: nil, full_address: "Bruce Road, Glenbrook, NSW, Australia"), double(country_code: "AU", lat: 1.1, lng: 2.1, accuracy: 6, city: "Somewhere else", state: "VIC", zip: nil, full_address: "Bruce Road, Somewhere else, VIC, Australia")]))

    l = GeocoderService.geocode("Bruce Road")
    expect(l.error).to be_nil
  end

  it "should error if the address is not a full street address but rather a suburb name or similar" do
    allow(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).and_return(double(all: [double(country_code: "AU", lat: 1, lng: 2, accuracy: 4, city: "Glenbrook", state: "NSW", zip: nil, full_address: "Glenbrook NSW, Australia")]))

    l = GeocoderService.geocode("Glenbrook, NSW")
    expect(l.error).to eq("Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’")
  end

  it "should list potential matches and they should be in Australia" do
    m = double(full_address: "Bathurst Rd, Orange NSW 2800, Australia", country_code: "AU", lat: nil, lng: nil, city: "Orange", state: "NSW", zip: "2800", accuracy: nil, success: true)
    all = [
      m,
      double(full_address: "Bathurst Rd, Katoomba NSW 2780, Australia", country_code: "AU", lat: nil, lng: nil, city: "Katoomba", state: "NSW", zip: "2780", accuracy: nil),
      double(full_address: "Bathurst Rd, Staplehurst, Kent TN12 0, UK", country_code: "UK", lat: nil, lng: nil, city: "Staplehurst", state: "Kent", zip: "TN12 0", accuracy: nil),
      double(full_address: "Bathurst Rd, Cape Town 7708, South Africa", country_code: "ZA", lat: nil, lng: nil, city: "Cape Town", state: nil, zip: "7708", accuracy: nil),
      double(full_address: "Bathurst Rd, Winnersh, Wokingham RG41 5, UK", country_code: "UK", lat: nil, lng: nil, city: "Winnersh", state: "Wokingham", zip: "RG41 5", accuracy: nil),
      double(full_address: "Bathurst Rd, Catonsville, MD 21228, USA", country_code: "US", lat: nil, lng: nil, city: "Catonsville", state: "MD", zip: "21228", accuracy: nil),
      double(full_address: "Bathurst Rd, Durban South 4004, South Africa", country_code: "ZA", lat: nil, lng: nil, city: "Durban South", state: nil, zip: "4004", accuracy: nil),
      double(full_address: "Bathurst Rd, Port Kennedy WA 6172, Australia", country_code: "AU", lat: nil, lng: nil, city: "Port Kennedy", state: "WA", zip: "6172", accuracy: nil),
      double(full_address: "Bathurst Rd, Campbell River, BC V9W, Canada", country_code: "CA", lat: nil, lng: nil, city: "Campbell River", state: "BC", zip: "V9W", accuracy: nil),
      double(full_address: "Bathurst Rd, Riverside, CA, USA", country_code: "US", lat: nil, lng: nil, city: "Riverside", state: "CA", zip: nil, accuracy: nil)
    ]
    allow(m).to receive_messages(all: all)
    allow(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).and_return(double(all: all))
    l = GeocoderService.geocode("Bathurst Rd")
    all = l.all
    expect(all.count).to eq(3)
    expect(all[0].full_address).to eq("Bathurst Rd, Orange NSW 2800")
    expect(all[1].full_address).to eq("Bathurst Rd, Katoomba NSW 2780")
    expect(all[2].full_address).to eq("Bathurst Rd, Port Kennedy WA 6172")
  end

  it "the first match should only return addresses in Australia" do
    m = double(full_address: "Sowerby St, Garfield NSW 2580, Australia", country_code: "AU", lat: nil, lng: nil, city: "Garfield", state: "NSW", zip: "2580", accuracy: nil, success: true)
    all = [
      double(full_address: "Sowerby St, Lawrence 9532, New Zealand", country_code: "NZ", lat: nil, lng: nil, city: "Lawrence", state: nil, zip: "9532", accuracy: nil),
      m,
      double(full_address: "Sowerby St, Sowerby, Halifax, Calderdale HX6 3, UK", country_code: "UK", lat: nil, lng: nil, city: "Sowerby", state: "Calderdale", zip: "HX6 3", accuracy: nil),
      double(full_address: "Sowerby St, Burnley, Lancashire BB12 8, UK", country_code: "UK", lat: nil, lng: nil, city: "Burnley", state: "Lancashire", zip: "BB12 8", accuracy: nil)
    ]
    allow(m).to receive_messages(all: all)
    allow(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).and_return(double(full_address: "Sowerby St, Lawrence 9532, New Zealand", all: all))
    l = GeocoderService.geocode("Sowerby St")
    expect(l.full_address).to eq("Sowerby St, Garfield NSW 2580")
    all = l.all
    expect(all.count).to eq(1)
    expect(all[0].full_address).to eq("Sowerby St, Garfield NSW 2580")
  end
end
