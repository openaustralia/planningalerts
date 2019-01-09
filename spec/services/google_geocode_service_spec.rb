# frozen_string_literal: true

require File.dirname(__FILE__) + "/../spec_helper"

describe "GoogleGeocodeService" do
  before(:each) do
    expect(Geokit::Geocoders::GoogleGeocoder).to receive(:geocode).with(address, bias: "au").and_return(geokit_result)
  end
  let(:result) { GoogleGeocodeService.call(address) }

  context "valid full address" do
    let(:address) { "24 Bruce Road, Glenbrook, NSW 2773" }
    let(:geokit_result) do
      double(success: true, all: [double(country_code: "AU", lat: -33.772609, lng: 150.624263, accuracy: 6, city: "Glenbrook", state: "NSW", zip: "2773", full_address: "24 Bruce Road, Glenbrook, NSW 2773, Australia")])
    end

    it "should geocode an address into a latitude and longitude by using the Google service" do
      expect(result.top.lat).to eq(-33.772609)
      expect(result.top.lng).to eq(150.624263)
    end

    it "should not error" do
      expect(result.error).to be_nil
    end
  end

  context "empty address" do
    let(:address) { "" }
    let(:geokit_result) do
      double(success: false, lat: nil, lng: nil, country_code: nil, accuracy: nil, all: [])
    end

    it "should return nil" do
      expect(result.top).to be_nil
    end

    it "should error" do
      expect(result.error).to eq("Please enter a street address")
    end
  end

  context "address that is not valid" do
    let(:address) { "rxsd23dfj" }
    let(:geokit_result) do
      double(success: false, lat: nil, lng: nil, country_code: nil, accuracy: nil, all: [])
    end

    it "should error" do
      expect(result.error).to eq("Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’")
    end
  end

  context "street address not in australia" do
    let(:address) { "New York" }
    let(:geokit_result) do
      double(success: true, lat: 1, lng: 2, country_code: "US", city: "New York", state: "NY", zip: nil, full_address: "New York, NY", accuracy: nil, all: [double(lat: 1, lng: 2, country_code: "US", city: "New York", state: "NY", zip: nil, full_address: "New York, NY", accuracy: nil)])
    end

    it "should error" do
      expect(result.error).to eq("Unfortunately we only cover Australia. It looks like that address is in another country.")
    end
  end

  context "address is just a suburb name" do
    let(:address) { "Glenbrook, NSW" }
    let(:geokit_result) do
      double(success: true, all: [double(country_code: "AU", lat: 1, lng: 2, accuracy: 4, city: "Glenbrook", state: "NSW", zip: nil, full_address: "Glenbrook NSW, Australia")])
    end

    it "should error" do
      expect(result.error).to eq("Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’")
    end
  end

  context "address with multiple matches" do
    let(:address) { "Bruce Road" }
    let(:geokit_result) do
      double(success: true, all:
        [double(country_code: "AU", lat: 1, lng: 2, accuracy: 6, city: "Glenbrook", state: "NSW", zip: nil, full_address: "Bruce Road, Glenbrook, NSW, Australia"), double(country_code: "AU", lat: 1.1, lng: 2.1, accuracy: 6, city: "Somewhere else", state: "VIC", zip: nil, full_address: "Bruce Road, Somewhere else, VIC, Australia")])
    end

    it "should not error" do
      expect(result.error).to be_nil
    end
  end

  context "another address with multiple matches" do
    let(:address) { "Bathurst Rd" }
    let(:geokit_result) do
      m = double(full_address: "Bathurst Rd, Orange NSW 2800, Australia", country_code: "AU", lat: nil, lng: nil, city: "Orange", state: "NSW", zip: "2800", accuracy: 5, success: true)
      all = [
        m,
        double(full_address: "Bathurst Rd, Katoomba NSW 2780, Australia", country_code: "AU", lat: nil, lng: nil, city: "Katoomba", state: "NSW", zip: "2780", accuracy: 5),
        double(full_address: "Bathurst Rd, Staplehurst, Kent TN12 0, UK", country_code: "UK", lat: nil, lng: nil, city: "Staplehurst", state: "Kent", zip: "TN12 0", accuracy: 5),
        double(full_address: "Bathurst Rd, Cape Town 7708, South Africa", country_code: "ZA", lat: nil, lng: nil, city: "Cape Town", state: nil, zip: "7708", accuracy: 5),
        double(full_address: "Bathurst Rd, Winnersh, Wokingham RG41 5, UK", country_code: "UK", lat: nil, lng: nil, city: "Winnersh", state: "Wokingham", zip: "RG41 5", accuracy: 5),
        double(full_address: "Bathurst Rd, Catonsville, MD 21228, USA", country_code: "US", lat: nil, lng: nil, city: "Catonsville", state: "MD", zip: "21228", accuracy: 5),
        double(full_address: "Bathurst Rd, Durban South 4004, South Africa", country_code: "ZA", lat: nil, lng: nil, city: "Durban South", state: nil, zip: "4004", accuracy: 5),
        double(full_address: "Bathurst Rd, Port Kennedy WA 6172, Australia", country_code: "AU", lat: nil, lng: nil, city: "Port Kennedy", state: "WA", zip: "6172", accuracy: 5),
        double(full_address: "Bathurst Rd, Campbell River, BC V9W, Canada", country_code: "CA", lat: nil, lng: nil, city: "Campbell River", state: "BC", zip: "V9W", accuracy: 5),
        double(full_address: "Bathurst Rd, Riverside, CA, USA", country_code: "US", lat: nil, lng: nil, city: "Riverside", state: "CA", zip: nil, accuracy: 5)
      ]
      # TODO: Refactor this
      allow(m).to receive_messages(all: all)
      double(success: true, all: all)
    end

    it "should list potential matches and they should be in Australia" do
      expect(result.all.count).to eq(3)
      expect(result.all[0].full_address).to eq("Bathurst Rd, Orange NSW 2800")
      expect(result.all[1].full_address).to eq("Bathurst Rd, Katoomba NSW 2780")
      expect(result.all[2].full_address).to eq("Bathurst Rd, Port Kennedy WA 6172")
    end
  end

  context "and another address with multiple matches" do
    let(:address) { "Sowerby St" }
    let(:geokit_result) do
      # TODO: Simplify this bit
      m = double(full_address: "Sowerby St, Garfield NSW 2580, Australia", country_code: "AU", lat: nil, lng: nil, city: "Garfield", state: "NSW", zip: "2580", accuracy: 5, success: true)
      all = [
        double(full_address: "Sowerby St, Lawrence 9532, New Zealand", country_code: "NZ", lat: nil, lng: nil, city: "Lawrence", state: nil, zip: "9532", accuracy: 5),
        m,
        double(full_address: "Sowerby St, Sowerby, Halifax, Calderdale HX6 3, UK", country_code: "UK", lat: nil, lng: nil, city: "Sowerby", state: "Calderdale", zip: "HX6 3", accuracy: 5),
        double(full_address: "Sowerby St, Burnley, Lancashire BB12 8, UK", country_code: "UK", lat: nil, lng: nil, city: "Burnley", state: "Lancashire", zip: "BB12 8", accuracy: 5)
      ]
      allow(m).to receive_messages(all: all)
      double(success: true, full_address: "Sowerby St, Lawrence 9532, New Zealand", all: all)
    end

    it "the first match should only return addresses in Australia" do
      expect(result.top.full_address).to eq("Sowerby St, Garfield NSW 2580")
      expect(result.all.count).to eq(1)
      expect(result.all[0].full_address).to eq("Sowerby St, Garfield NSW 2580")
    end
  end
end
