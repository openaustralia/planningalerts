# frozen_string_literal: true

require File.dirname(__FILE__) + "/../spec_helper"

describe "GoogleGeocodeService" do
  let(:result) do
    VCR.use_cassette(:google_geocoder) do
      GoogleGeocodeService.call(address)
    end
  end

  context "valid full address" do
    let(:address) { "24 Bruce Road, Glenbrook, NSW 2773" }

    it "should geocode an address into a latitude and longitude by using the Google service" do
      expect(result.top.lat).to eq(-33.7726179)
      expect(result.top.lng).to eq(150.6242341)
      expect(result.top.suburb).to eq "Glenbrook"
      expect(result.top.state).to eq "NSW"
      expect(result.top.postcode).to eq "2773"
      expect(result.top.full_address).to eq "24 Bruce Rd, Glenbrook NSW 2773"
    end

    it "should not error" do
      expect(result.error).to be_nil
    end
  end

  context "empty address" do
    let(:address) { "" }

    it "should return nil" do
      expect(result.top).to be_nil
    end

    it "should error" do
      expect(result.error).to eq("Please enter a street address")
    end
  end

  context "address that is not valid" do
    let(:address) { "rxsd23dfj" }

    it "should error" do
      expect(result.error).to eq("Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’")
    end
  end

  context "street address not in australia" do
    let(:address) { "New York" }

    it "should error" do
      expect(result.error).to eq("Unfortunately we only cover Australia. It looks like that address is in another country.")
    end
  end

  context "address is just a suburb name" do
    let(:address) { "Glenbrook, NSW" }

    it "should error" do
      expect(result.error).to eq("Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’")
    end
  end

  context "address with multiple matches" do
    let(:address) { "Bruce Road" }

    it "should not error" do
      expect(result.error).to be_nil
    end
  end

  context "another address with multiple matches" do
    let(:address) { "Bathurst Rd" }

    it "should list potential matches and they should be in Australia" do
      expect(result.all.count).to eq(2)
      expect(result.all[0].full_address).to eq("Bathurst Rd, Orange NSW 2800")
      expect(result.all[1].full_address).to eq("Bathurst Rd, Katoomba NSW 2780")
    end
  end

  context "and another address with multiple matches" do
    let(:address) { "Sowerby St" }

    it "the first match should only return addresses in Australia" do
      expect(result.top.full_address).to eq("Sowerby St, Muswellbrook NSW 2333")
      expect(result.all.count).to eq(3)
      expect(result.all[0].full_address).to eq("Sowerby St, Muswellbrook NSW 2333")
      expect(result.all[1].full_address).to eq("Sowerby St, Oran Park NSW 2570")
      expect(result.all[2].full_address).to eq("Sowerby St, Goulburn NSW 2580")
    end
  end

  context "valid address that google only gets partial match on" do
    let(:address) { "11 Explorers Way Westdale NSW 2340" }

    it "should error" do
      expect(result.error).to eq "Sorry we only got a partial match on that address"
    end
  end
end
