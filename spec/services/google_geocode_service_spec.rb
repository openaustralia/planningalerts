# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"

describe "GoogleGeocodeService" do
  # This is a special maps api key which is just for running these tests
  # It is disabled in the google cloud console:
  # https://console.cloud.google.com/apis/credentials/key/f9bf39f1-8c05-4c64-9646-2691ab734432?project=planningalerts-214303&authuser=1&organizationId=142099235345
  # Normally this isn't a problem as requests are recorded with vcr and played
  # back so no actual external web requests are run during tests.
  let(:key) { "AIzaSyCmIXlJq_d6R-9vaPDr1Fx5eUr1Jl1Oc6Q" }

  let(:result) do
    VCR.use_cassette(:google_geocoder) do
      GoogleGeocodeService.call(address:, key:)
    end
  end
  let(:error) { result.error }

  context "with valid full address" do
    let(:address) { "24 Bruce Road, Glenbrook, NSW 2773" }

    it "geocodes an address into a latitude and longitude by using the Google service" do
      expect(result.top.lat).to eq(-33.7726179)
      expect(result.top.lng).to eq(150.6242341)
      expect(result.top.suburb).to eq "Glenbrook"
      expect(result.top.state).to eq "NSW"
      expect(result.top.postcode).to eq "2773"
      expect(result.top.full_address).to eq "24 Bruce Rd, Glenbrook NSW 2773"
    end

    it "does not error" do
      expect(result.error).to be_nil
    end
  end

  context "with empty address" do
    let(:address) { "" }

    it "returns nil" do
      expect(result.top).to be_nil
    end

    it "errors" do
      expect(result.error).to eq("Please enter a street address")
    end
  end

  context "with address that is not valid" do
    let(:address) { "rxsd23dfj" }

    it "errors" do
      expect(result.error).to eq("Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’")
    end
  end

  context "with street address not in australia" do
    let(:address) { "New York" }

    it "errors" do
      expect(result.error).to eq("Unfortunately we only cover Australia. It looks like that address is in another country.")
    end
  end

  context "with address is just a suburb name" do
    let(:address) { "Glenbrook, NSW" }

    it "errors" do
      expect(result.error).to eq("Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’")
    end
  end

  context "with address with multiple matches" do
    let(:address) { "Bruce Road" }

    it "does not error" do
      expect(result.error).to be_nil
    end
  end

  context "with bathurst road address with multiple matches" do
    let(:address) { "Bathurst Rd" }

    it "lists potential matches and they should be in Australia" do
      expect(result.all.count).to eq(2)
      expect(result.all[0].full_address).to eq("Bathurst Rd, Orange NSW 2800")
      expect(result.all[1].full_address).to eq("Bathurst Rd, Katoomba NSW 2780")
    end
  end

  context "with sowerby street address with multiple matches" do
    let(:address) { "Sowerby St" }

    it "the first match should only return addresses in Australia" do
      expect(result.top.full_address).to eq("Sowerby St, Muswellbrook NSW 2333")
      expect(result.all.count).to eq(3)
      expect(result.all[0].full_address).to eq("Sowerby St, Muswellbrook NSW 2333")
      expect(result.all[1].full_address).to eq("Sowerby St, Oran Park NSW 2570")
      expect(result.all[2].full_address).to eq("Sowerby St, Goulburn NSW 2580")
    end
  end

  context "with valid address that google only gets partial match on" do
    let(:address) { "11 Explorers Way Westdale NSW 2340" }

    it "errors" do
      expect(result.error).to eq "Sorry we only got a partial match on that address"
    end
  end

  # See https://github.com/openaustralia/planningalerts/issues/1281
  # for a list of addresses that were causing problems that should do something more
  # sensible now which is error so that a wrong geocoding result is not recorded
  describe "addresses that were causing problems with the google geocoder before" do
    context "with Wickham Street Marsden Park address" do
      let(:address) { "1 Wickham Street Marsden Park NSW 2765" }

      it { expect(error).not_to be_nil }
    end

    context "with Flagstone address" do
      let(:address) { "7 Bradfield Street Flagstone QLD 4280" }

      it { expect(error).not_to be_nil }
    end

    context "with Park Ridge address" do
      let(:address) { "21 Beck Street Park Ridge QLD 4125" }

      it { expect(error).not_to be_nil }
    end

    context "with Lloyd address" do
      let(:address) { "8 Bennelong Cres Lloyd NSW 2650" }

      it { expect(error).not_to be_nil }
    end

    context "with Cliftleigh address" do
      let(:address) { "16 Hilltop Gr, Cliftleigh 2321 NSW" }

      it { expect(error).not_to be_nil }
    end

    context "with Narrara address" do
      let(:address) { "17 Isabella Close, Narara NSW 2250" }

      it { expect(error).not_to be_nil }
    end

    context "with Riverstone address" do
      let(:address) { "41 Foxall Street Riverstone NSW 2765" }

      it { expect(error).not_to be_nil }
    end

    context "with Larkin Street Marsden Park address" do
      let(:address) { "29 Larkin Street Marsden Park NSW 2765" }

      it { expect(error).not_to be_nil }
    end
  end
end
