# frozen_string_literal: true

require "spec_helper"

describe Application do
  let(:authority) { create(:authority) }

  describe "validation" do
    describe "date_scraped" do
      it { expect(build(:application, date_scraped: nil)).not_to be_valid }
    end

    describe "council_reference" do
      it { expect(build(:application, council_reference: "")).not_to be_valid }

      context "one application already exists" do
        before :each do
          create(:geocoded_application, council_reference: "A01", authority: authority)
        end
        let(:authority2) { create(:authority, full_name: "A second authority") }

        it { expect(build(:geocoded_application, council_reference: "A01", authority: authority)).not_to be_valid }
        it { expect(build(:geocoded_application, council_reference: "A02", authority: authority)).to be_valid }
        it { expect(build(:geocoded_application, council_reference: "A01", authority: authority2)).to be_valid }
      end
    end

    describe "address" do
      it { expect(build(:application, address: "")).not_to be_valid }
    end

    describe "description" do
      it { expect(build(:application, description: "")).not_to be_valid }
    end

    describe "info_url" do
      it { expect(build(:application, info_url: "")).not_to be_valid }
      it { expect(build(:application, info_url: "http://blah.com?p=1")).to be_valid }
      it { expect(build(:application, info_url: "foo")).not_to be_valid }
    end

    describe "comment_url" do
      it { expect(build(:application, comment_url: nil)).to be_valid }
      it { expect(build(:application, comment_url: "http://blah.com?p=1")).to be_valid }
      it { expect(build(:application, comment_url: "mailto:m@foo.com?subject=hello+sir")).to be_valid }
      it { expect(build(:application, comment_url: "foo")).not_to be_valid }
      it { expect(build(:application, comment_url: "mailto:council@lakemac.nsw.gov.au?Subject=Redhead%20Beach%20&%20Surf%20Life%20Saving%20Club,%202A%20Beach%20Road,%20REDHEAD%20%20NSW%20%202290%20DA-1699/2014")).to be_valid }
    end

    describe "date_received" do
      it { expect(build(:application, date_received: nil)).to be_valid }

      context "the date today is 1 january 2001" do
        around do |test|
          Timecop.freeze(Date.new(2001, 1, 1)) { test.run }
        end

        it { expect(build(:application, date_received: Date.new(2002, 1, 1))).not_to be_valid }
        it { expect(build(:application, date_received: Date.new(2000, 1, 1))).to be_valid }
      end
    end

    describe "on_notice" do
      it { expect(build(:application, on_notice_from: nil, on_notice_to: nil)).to be_valid }
      it { expect(build(:application, on_notice_from: Date.new(2001, 1, 1), on_notice_to: Date.new(2001, 2, 1))).to be_valid }
      it { expect(build(:application, on_notice_from: nil, on_notice_to: Date.new(2001, 2, 1))).to be_valid }
      it { expect(build(:application, on_notice_from: Date.new(2001, 1, 1), on_notice_to: nil)).to be_valid }
      it { expect(build(:application, on_notice_from: Date.new(2001, 2, 1), on_notice_to: Date.new(2001, 1, 1))).not_to be_valid }
    end
  end

  describe "getting DA descriptions" do
    it "should allow applications to be blank" do
      expect(build(:application, description: "").description).to eq("")
    end

    it "should allow the application description to be nil" do
      expect(build(:application, description: nil).description).to be_nil
    end

    it "should start descriptions with a capital letter" do
      expect(build(:application, description: "a description").description).to eq("A description")
    end

    it "should fix capitilisation of descriptions all in caps" do
      expect(build(:application, description: "DWELLING").description).to eq("Dwelling")
    end

    it "should not capitalise descriptions that are partially in lowercase" do
      expect(build(:application, description: "To merge Owners Corporation").description).to eq("To merge Owners Corporation")
    end

    it "should capitalise the first word of each sentence" do
      expect(build(:application, description: "A SENTENCE. ANOTHER SENTENCE").description).to eq("A sentence. Another sentence")
    end

    it "should only capitalise the word if it's all lower case" do
      expect(build(:application, description: "ab sentence. AB SENTENCE. aB sentence. Ab sentence").description).to eq("Ab sentence. AB SENTENCE. aB sentence. Ab sentence")
    end

    it "should allow blank sentences" do
      expect(build(:application, description: "A poorly.    . formed sentence . \n").description).to eq("A poorly. . Formed sentence. ")
    end
  end

  describe "getting addresses" do
    it "should convert words to first letter capitalised form" do
      expect(build(:application, address: "1 KINGSTON AVENUE, PAKENHAM").address).to eq("1 Kingston Avenue, Pakenham")
    end

    it "should not convert words that are not already all in upper case" do
      expect(build(:application, address: "In the paddock next to the radio telescope").address).to eq("In the paddock next to the radio telescope")
    end

    it "should handle a mixed bag of lower and upper case" do
      expect(build(:application, address: "63 Kimberley drive, SHAILER PARK").address).to eq("63 Kimberley drive, Shailer Park")
    end

    it "should not affect dashes in the address" do
      expect(build(:application, address: "63-81").address).to eq("63-81")
    end

    it "should not affect abbreviations like the state names" do
      expect(build(:application, address: "1 KINGSTON AVENUE, PAKENHAM VIC 3810").address).to eq("1 Kingston Avenue, Pakenham VIC 3810")
    end

    it "should not affect the state names" do
      expect(build(:application, address: "QLD VIC NSW SA ACT TAS WA NT").address).to eq("QLD VIC NSW SA ACT TAS WA NT")
    end

    it "should not affect the state names with punctuation" do
      expect(build(:application, address: "QLD. ,VIC ,NSW, !SA /ACT/ TAS: WA, NT;").address).to eq("QLD. ,VIC ,NSW, !SA /ACT/ TAS: WA, NT;")
    end

    it "should not affect codes" do
      expect(build(:application, address: "R79813 24X").address).to eq("R79813 24X")
    end
  end

  describe "on saving" do
    it "should geocode the address" do
      loc = GeocoderResults.new(
        [
          GeocodedLocation.new(
            lat: -33.772609,
            lng: 150.624263,
            suburb: "Glenbrook",
            state: "NSW",
            postcode: "2773",
            full_address: "Glenbrook, NSW 2773"
          )
        ],
        nil
      )
      expect(GeocodeService).to receive(:call).with("24 Bruce Road, Glenbrook, NSW").and_return(loc)
      a = create(:application, address: "24 Bruce Road, Glenbrook, NSW", council_reference: "r1", date_scraped: Time.zone.now)
      expect(a.lat).to eq(loc.top.lat)
      expect(a.lng).to eq(loc.top.lng)
    end

    it "should log an error if the geocoder can't make sense of the address" do
      expect(GeocodeService).to receive(:call).with("dfjshd").and_return(
        GeocoderResults.new([], "something went wrong")
      )
      logger = double("Logger")
      expect(logger).to receive(:error).with("Couldn't geocode address: dfjshd (something went wrong)")

      a = build(:application, address: "dfjshd", council_reference: "r1", date_scraped: Time.zone.now)
      allow(a).to receive(:logger).and_return(logger)

      a.save!
      expect(a.lat).to be_nil
      expect(a.lng).to be_nil
    end
  end

  describe "#official_submission_period_expired?" do
    let(:application) { create(:geocoded_application) }

    context "when the ‘on notice to’ date is not set" do
      before { application.update(on_notice_to: nil) }

      it { expect(application.official_submission_period_expired?).to be_falsey }
    end

    context "when the ‘on notice to’ date has passed", focus: true do
      before { application.update(on_notice_to: Time.zone.today - 1.day) }

      it { expect(application.official_submission_period_expired?).to be true }
    end

    context "when the ‘on notice to’ date is in the future" do
      before { application.update(on_notice_to: Time.zone.today + 1.day) }

      it { expect(application.official_submission_period_expired?).to be false }
    end
  end

  describe "#current_councillors_for_authority" do
    let(:application) { create(:geocoded_application, authority: authority) }

    context "when there are no councillors" do
      it { expect(application.current_councillors_for_authority).to eq nil }
    end

    context "when there are councillors" do
      let(:councillor1) { create(:councillor, authority: authority) }
      let(:councillor2) { create(:councillor, authority: authority) }
      let(:councillor3) { create(:councillor, authority: authority) }

      before do
        councillor1
        councillor2
        councillor3
      end

      it { expect(application.current_councillors_for_authority).to match_array [councillor1, councillor2, councillor3] }
    end

    context "when there are councillors but not for the application’s authority" do
      before do
        create(:councillor, authority: create(:authority))
      end

      it { expect(application.current_councillors_for_authority).to eq nil }
    end

    context "when there are councillors but not all are current" do
      let(:current_councillor) { create(:councillor, current: true, authority: authority) }
      let(:former_councillor) { create(:councillor, current: false, authority: authority) }

      before do
        current_councillor
        former_councillor
      end

      it "only includes the current ones" do
        expect(application.current_councillors_for_authority).to eq [current_councillor]
      end
    end
  end

  describe "#councillors_available_for_contact" do
    let(:application) { create(:geocoded_application, authority: authority) }

    context "when there are no councillors" do
      context "and the feature is disabled for the authority" do
        before do
          allow(authority).to receive(:write_to_councillors_enabled?).and_return false
        end

        it { expect(application.councillors_available_for_contact).to eq nil }
      end

      context "and the feature is enabled for the authority" do
        before do
          allow(authority).to receive(:write_to_councillors_enabled?).and_return true
        end

        it { expect(application.councillors_available_for_contact).to eq nil }
      end
    end

    context "when there are councillors" do
      let(:councillor1) { create(:councillor, authority: authority) }
      let(:councillor2) { create(:councillor, authority: authority) }
      let(:councillor3) { create(:councillor, authority: authority) }

      before do
        councillor1
        councillor2
        councillor3
      end

      context "but the feature is disabled for the authority" do
        before do
          allow(authority).to receive(:write_to_councillors_enabled?).and_return false
        end

        it { expect(application.councillors_available_for_contact).to eq nil }
      end

      context "and the feature is enabled for the authority" do
        before do
          allow(authority).to receive(:write_to_councillors_enabled?).and_return true
        end

        it { expect(application.councillors_available_for_contact).to match_array [councillor1, councillor2, councillor3] }
      end
    end
  end

  describe "versioning" do
    let(:application) do
      Application.create!(
        authority: authority,
        date_scraped: Date.new(2001, 1, 10),
        council_reference: "123/45",
        address: "Some kind of address",
        description: "A really nice change",
        info_url: "http://foo.com",
        comment_url: "http://foo.com/comment",
        date_received: Date.new(2001, 1, 1),
        on_notice_from: Date.new(2002, 1, 1),
        on_notice_to: Date.new(2002, 2, 1),
        lat: 1.0,
        lng: 2.0,
        suburb: "Sydney",
        state: "NSW",
        postcode: "2000"
      )
    end

    it "should automatically create a version on creating an application" do
      expect(application.versions.count).to eq 1
    end

    it "should populate the version with the current information" do
      version = application.versions.first
      expect(version.application).to eq application
      expect(version.previous_version).to be_nil
      expect(version.authority).to eq authority
      expect(version.date_scraped).to eq Date.new(2001, 1, 10)
      expect(version.council_reference).to eq "123/45"
      expect(version.address).to eq "Some kind of address"
      expect(version.description).to eq "A really nice change"
      expect(version.info_url).to eq "http://foo.com"
      expect(version.comment_url).to eq "http://foo.com/comment"
      expect(version.date_received).to eq Date.new(2001, 1, 1)
      expect(version.on_notice_from).to eq Date.new(2002, 1, 1)
      expect(version.on_notice_to).to eq Date.new(2002, 2, 1)
      expect(version.lat).to eq 1.0
      expect(version.lng).to eq 2.0
      expect(version.suburb).to eq "Sydney"
      expect(version.state).to eq "NSW"
      expect(version.postcode).to eq "2000"
      expect(version.current).to eq true
    end

    context "updated application with new data" do
      before(:each) { application.update(address: "A better kind of address") }

      it "should create a new version when updating" do
        expect(application.versions.count).to eq 2
      end

      it "should have the new value" do
        expect(application.address).to eq "A better kind of address"
      end

      it "should have the new value in the latest version" do
        expect(application.versions[0].address).to eq "A better kind of address"
      end

      it "should point to the previous version in the latest version" do
        expect(application.versions[0].previous_version).to eq application.versions[1]
      end

      it "should have the old value in the previous version" do
        expect(application.versions[1].address).to eq "Some kind of address"
      end

      it "the latest version should now be current" do
        expect(application.versions[0].current).to eq true
      end

      it "the previous version should now be not current" do
        expect(application.versions[1].current).to eq false
      end
    end

    context "updated application with unchanged data" do
      before(:each) { application.update(address: "Some kind of address") }

      it "should not create a new version when the data hasn't changed" do
        expect(application.versions.count).to eq 1
      end
    end

    describe "reloading" do
      it "should reload versioned data" do
        application = create(:geocoded_application, date_scraped: Date.new(2001, 1, 1))
        application2 = Application.find(application.id)
        # Not testing all the version attributes - just a selection
        expect(application2.date_scraped).to eq Date.new(2001, 1, 1)
        expect(application2.address).to eq "A test address"
        expect(application2.description).to eq "Pretty"
        expect(application2.info_url).to eq "http://foo.com"
      end
    end

    describe "N+1 queries" do
      it "should not do too many sql queries" do
        5.times { create(:geocoded_application) }
        expect(ActiveRecord::Base.connection).to receive(:exec_query).at_most(2).times.and_call_original
        Application.all.map(&:description)
      end
    end
  end
end
