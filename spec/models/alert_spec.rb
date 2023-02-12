# frozen_string_literal: true

require "spec_helper"

describe Alert do
  let(:address) { "24 Bruce Road, Glenbrook" }

  describe "confirm_id" do
    let(:object) do
      VCR.use_cassette("planningalerts") { create(:alert) }
    end

    it "is a string" do
      expect(object.confirm_id).to be_instance_of(String)
    end

    it "is not the same for two different objects" do
      another_object = VCR.use_cassette("planningalerts") do
        create(:alert)
      end

      expect(object.confirm_id).not_to eq another_object.confirm_id
    end

    it "only includes hex characters and is exactly twenty characters long" do
      expect(object.confirm_id).to match(/^[0-9a-f]{20}$/)
    end
  end

  context "when the geocoder doesn't need to run" do
    let(:alert) { build(:alert, address: "foo", lat: 1, lng: 2) }

    it "doesn't validate the address" do
      expect(alert).to be_valid
    end
  end

  context "when the geocoder does need to run" do
    let(:alert) do
      build(:alert, address: "Bruce Rd", lat: nil, lng: nil)
    end

    it "is valid when the geocoder returns no errors" do
      mock_geocoder_valid_address_response

      expect(alert).to be_valid
    end

    it "is invalid if there was an error geocoding the address" do
      mock_geocoder_error_response

      alert.save

      expect(alert).to be_invalid
      expect(alert.errors[:address]).to eq(["some error message"])
    end

    it "is invalid if the geocoder found multiple locations for the address" do
      mock_geocoder_multiple_locations_response

      alert.save

      expect(alert).not_to be_valid
      expect(alert.errors[:address]).to eq(["isn't complete. Please enter a full street address, including suburb and state, e.g. Bruce Rd, VIC 3885"])
    end
  end

  it "is able to accept location information if it is already known and so not use the geocoder" do
    allow(GoogleGeocodeService).to receive(:call)
    alert = create(:alert, lat: 1.0, lng: 2.0)

    expect(GoogleGeocodeService).not_to have_received(:call)
    expect(alert.lat).to eq(1.0)
    expect(alert.lng).to eq(2.0)
  end

  describe "geocoding" do
    before do
      allow(GoogleGeocodeService).to receive(:call).with(address).and_return(
        GeocoderResults.new(
          [
            GeocodedLocation.new(
              lat: -33.7726179,
              lng: 150.6242341,
              suburb: "Glenbrook",
              state: "NSW",
              postcode: "2773",
              full_address: "24 Bruce Rd, Glenbrook NSW 2773"
            )
          ],
          nil
        )
      )
    end

    it "happens automatically on saving" do
      alert = create(:alert, address:, lat: nil, lng: nil)

      expect(alert.lat).to eq(-33.7726179)
      expect(alert.lng).to eq(150.6242341)
    end

    it "replaces the address with the full resolved address obtained by geocoding" do
      alert = create(:alert, address: "24 Bruce Road, Glenbrook", lat: nil, lng: nil)

      expect(alert.address).to eq("24 Bruce Rd, Glenbrook NSW 2773")
    end
  end

  it "is able to store the attribute location" do
    alert = described_class.new
    alert.location = Location.new(lat: 1.0, lng: 2.0)
    expect(alert.lat).to eq(1.0)
    expect(alert.lng).to eq(2.0)
    expect(alert.location.lat).to eq(1.0)
    expect(alert.location.lng).to eq(2.0)
  end

  it "handles location being nil" do
    alert = described_class.new
    alert.location = nil
    expect(alert.lat).to be_nil
    expect(alert.lng).to be_nil
    expect(alert.location).to be_nil
  end

  describe "address" do
    let(:address) { "1234 Marine Parade, NSW" }
    let(:user) { create(:user) }

    context "when there is already an alert for 1234 Marine Parade" do
      before do
        create(:alert, user:, address:)
      end

      it "is not valid for another alert at the same address for the same user" do
        expect(build(:alert, user:, address:)).not_to be_valid
      end

      it "is valid for another alert at a different address for the same user" do
        expect(build(:alert, user:, address: "Another address")).to be_valid
      end

      it "is valid for another alert at the same address for a different user" do
        expect(build(:confirmed_alert, address:)).to be_valid
      end

      it "is valid for an unsubscribed alert at the same address for the same user" do
        expect(build(:unsubscribed_alert, user:, address:)).to be_valid
      end

      it "is valid for two unsubscribed alerts at the same address for the same user" do
        create(:unsubscribed_alert, user:, address:)
        expect(build(:unsubscribed_alert, user:, address:)).to be_valid
      end
    end

    context "when there is already an unsubscribed alert for 1234 Marine Parade" do
      before do
        create(:unsubscribed_alert, user:, address:)
      end

      it "is valid for another alert at the same address for the same user" do
        expect(build(:alert, user:, address:)).to be_valid
      end

      it "is valid for another unsubscribed alert at the same address for the same user" do
        expect(build(:unsubscribed_alert, user:, address:)).to be_valid
      end
    end
  end

  describe "radius_meters" do
    it "has a number" do
      alert = build(:alert, radius_meters: "a")
      expect(alert).not_to be_valid
      expect(alert.errors[:radius_meters]).to eq(["is not a number", "is not included in the list"])
    end

    it "is greater than zero" do
      alert = build(:alert, radius_meters: "0")
      expect(alert).not_to be_valid
      expect(alert.errors[:radius_meters]).to eq(["isn't selected", "is not included in the list"])
    end

    it "is only one of the allowed values" do
      alert = build(:alert, radius_meters: "300")
      expect(alert).not_to be_valid
      expect(alert.errors[:radius_meters]).to eq(["is not included in the list"])
    end

    it "is valid when it is one of the allowed values" do
      alert = build(:alert, radius_meters: "2000")
      expect(alert).to be_valid
    end
  end

  describe "confirmed" do
    it "is false when alert is created" do
      expect(create(:alert).confirmed).to be false
    end

    it "is able to be set to false" do
      alert = build(:alert)
      alert.confirmed = false
      alert.save!
      expect(alert.confirmed).to be(false)
    end

    it "is able to set to true" do
      alert = build(:alert)
      alert.confirmed = true
      alert.save!
      expect(alert.confirmed).to be(true)
    end
  end

  describe "#geocode_from_address" do
    let(:original_address) { "24 Bruce Road, Glenbrook" }

    it "sets the address to the full address returned from the geocoder" do
      mock_geocoder_valid_address_response
      alert = build(:alert, address: original_address, lat: nil, lng: nil)

      alert.geocode_from_address

      expect(alert.address).to eq "24 Bruce Rd, Glenbrook, VIC 3885"
    end

    it "sets the lat and lng" do
      mock_geocoder_valid_address_response
      alert = build(:alert, address: original_address, lat: nil, lng: nil)

      alert.geocode_from_address

      expect(alert.lat).to eq(-33.772607)
      expect(alert.lng).to eq(150.624245)
    end

    context "when there is an error geocoding" do
      it "doesn't update any values" do
        mock_geocoder_error_response

        alert = build(:alert, address: original_address, lat: nil, lng: nil)

        alert.geocode_from_address

        expect(alert.address).to eq original_address
        expect(alert.location).to be_nil
      end
    end

    context "when the geocoder finds multiple locations" do
      it "doesn't update any values" do
        mock_geocoder_multiple_locations_response
        alert = build(:alert, address: original_address, lat: nil, lng: nil)

        alert.geocode_from_address

        expect(alert.address).to eq original_address
        expect(alert.location).to be_nil
      end
    end
  end

  describe "#geocoded?" do
    it { expect(build(:alert, address: "foo", lat: nil, lng: nil).geocoded?).to be false }
    it { expect(build(:alert, address: "foo", lat: 1, lng: 2).geocoded?).to be true }
  end

  describe "#unsubscribe!" do
    let(:alert) { create(:alert) }

    it "unsubscribes the alert" do
      alert.unsubscribe!

      expect(alert).to be_unsubscribed
    end

    it "sets the unsubscribed_at time" do
      action_time = Time.utc(2016, 11, 3, 15, 29)

      Timecop.freeze(action_time) { alert.unsubscribe! }

      expect(alert.unsubscribed_at).to eql action_time
    end
  end

  describe "#recent_new_applications" do
    let(:alert) { create(:alert, last_sent:, radius_meters:) }

    # Position test application around the point of the alert
    let(:p1) { alert.location.endpoint(0.0, 501.0) } # 501 m north of alert
    let(:p2) { alert.location.endpoint(0.0, 499.0) } # 499 m north of alert
    let(:p3) { alert.location.endpoint(45.0, Math.sqrt(2) * 499) } # Just inside the NE corner of a box centred on the alert (of size 2 * 499m)
    let(:p4) { alert.location.endpoint(90.0, 499.0) } # 499 m east of alert

    let!(:app1) { create(:geocoded_application, lat: p1.lat, lng: p1.lng, date_scraped: 5.minutes.ago) }
    let!(:app2) { create(:geocoded_application, lat: p2.lat, lng: p2.lng, date_scraped: 12.hours.ago) }
    let!(:app3) { create(:geocoded_application, lat: p3.lat, lng: p3.lng, date_scraped: 2.days.ago) }
    let!(:app4) { create(:geocoded_application, lat: p4.lat, lng: p4.lng, date_scraped: 4.days.ago) }

    context "with a search radius which includes all applications" do
      let(:radius_meters) { 2000 }

      context "when never before sent an alert" do
        let(:last_sent) { nil }

        it "returns applications that have been scraped in the last twenty four hours if the user has never had an alert" do
          expect(alert.recent_new_applications).to contain_exactly(app1, app2)
        end
      end

      context "when last sent an alert 3 days ago" do
        let(:last_sent) { 3.days.ago }

        it "returns applications that have been scraped since the last time the user was sent an alert" do
          expect(alert.recent_new_applications).to contain_exactly(app1, app2, app3)
        end

        context "when a couple of applications are updated one day ago" do
          before do
            CreateOrUpdateApplicationService.call(
              authority: app4.authority,
              council_reference: app4.council_reference,
              attributes: {
                date_scraped: 1.day.ago,
                description: "A new description"
              }
            )
            CreateOrUpdateApplicationService.call(
              authority: app2.authority,
              council_reference: app2.council_reference,
              attributes: {
                date_scraped: 1.day.ago,
                description: "A new description"
              }
            )
          end

          it "onlies include applications initially scraped within the last 3 days" do
            expect(alert.recent_new_applications).to contain_exactly(app1, app2, app3)
          end
        end

        context "when one application has an updated location (way off in the distance)" do
          before do
            p = alert.location.endpoint(0.0, 10000.0)
            CreateOrUpdateApplicationService.call(
              authority: app2.authority,
              council_reference: app2.council_reference,
              attributes: {
                lat: p.lat,
                lng: p.lng
              }
            )
          end

          it "does not include the application with the updated address" do
            expect(alert.recent_new_applications).to contain_exactly(app1, app3)
          end
        end
      end

      context "when last sent an alert 5 days ago" do
        let(:last_sent) { 5.days.ago }

        it "returns applications that have been scraped since the last time the user was sent an alert" do
          expect(alert.recent_new_applications).to contain_exactly(app1, app2, app3, app4)
        end
      end
    end

    context "with a reduced search radius of 500 metres" do
      # We're setting the actual radius below. We're just using this value to get
      # a valid initial record
      let(:radius_meters) { 800 }

      # Using last_sent of 5 days ago to ensure that otherwise all applications
      # would be included if it wasn't for the search radius
      context "when last sent an alert 5 days ago" do
        let(:last_sent) { 5.days.ago }

        it "returns applications within the user's search area" do
          # Doing this hacky workaround so that we can have this unusual radius
          alert.radius_meters = 500
          alert.save!(validate: false)
          expect(alert.recent_new_applications).to contain_exactly(app2, app4)
        end
      end
    end
  end

  describe "#new_comments" do
    let(:alert) { create(:alert, address:, radius_meters: 2000) }
    let(:p1) { alert.location.endpoint(0.0, 501.0) } # 501 m north of alert
    let(:application) { create(:application, lat: p1.lat, lng: p1.lng, suburb: "", state: "", postcode: "") }

    it "sees a new comment when there are new comments on an application" do
      comment1 = create(:confirmed_comment, application:)

      expect(alert.new_comments).to eql [comment1]
    end

    it "only sees two new comments when there are two new comments on a single application" do
      comment1 = create(:confirmed_comment, application:)
      comment2 = create(:confirmed_comment, application:)

      expect(alert.new_comments).to eql [comment1, comment2]
    end

    it "does not see old confirmed comments" do
      old_comment = create(:confirmed_comment,
                           confirmed_at: alert.cutoff_time - 1,
                           application:)

      expect(alert.new_comments).not_to eql [old_comment]
    end

    it "does not see unconfirmed comments" do
      unconfirmed_comment = create(:unconfirmed_comment, application:)

      expect(alert.new_comments).not_to eql [unconfirmed_comment]
    end

    it "does not see hidden comments" do
      hidden_comment = create(:confirmed_comment, hidden: true, application:)

      expect(alert.new_comments).not_to eql [hidden_comment]
    end
  end

  describe "#applications_with_new_comments" do
    let(:alert) { create(:alert, address:, radius_meters: 2000, lat: 1.0, lng: 2.0) }
    let(:near_application) do
      create(:application,
             lat: 1.0,
             lng: 2.0,
             address:,
             suburb: "Glenbrook",
             state: "NSW",
             postcode: "2773")
    end
    let(:far_away_application) do
      # 5001 m north of alert
      create(:application,
             lat: alert.location.endpoint(0.0, 5001.0).lat,
             lng: alert.location.endpoint(0.0, 5001.0).lng,
             address:,
             suburb: "Glenbrook",
             state: "NSW",
             postcode: "2773")
    end

    context "when there are no new comments near by" do
      it { expect(alert.applications_with_new_comments).to eq [] }
    end

    context "when there is a new comment near by" do
      it "returns the application it belongs to" do
        create(:confirmed_comment, application: near_application)

        expect(alert.applications_with_new_comments).to eq [near_application]
      end
    end

    context "when there is an old comment near by" do
      it "does not return the application it belongs to" do
        create(:confirmed_comment,
               confirmed_at: alert.cutoff_time - 1,
               application: near_application)

        expect(alert.applications_with_new_comments).to eq []
      end
    end

    context "when there is an unconfirmed comment near by" do
      it "does not return the application it belongs to" do
        create(:unconfirmed_comment, application: near_application)

        expect(alert.applications_with_new_comments).to eq []
      end
    end

    context "when there is a hidden comment near by" do
      it "does not return the application it belongs to" do
        create(:confirmed_comment, hidden: true, application: near_application)

        expect(alert.applications_with_new_comments).to eq []
      end
    end

    context "when there is a new comment far away" do
      it "does not return the application it belongs to" do
        create(:confirmed_comment, application: far_away_application)

        expect(alert.applications_with_new_comments).to eq []
      end
    end
  end

  # Related to https://github.com/openaustralia/planningalerts/issues/1547
  context "with a problematic alert seen in production" do
    it "does something sensible" do
      alert = create(
        :alert,
        last_sent: Time.utc(2021, 9, 9, 16, 28, 49),
        lat: -32.9364626,
        lng: 151.6784514,
        radius_meters: 2000
      )
      authority = create(:authority, disabled: false)
      allow(GeocodeService).to receive(:call).with(", NSW").and_return(GeocoderResults.new([], "Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’"))
      CreateOrUpdateApplicationService.call(
        authority:,
        council_reference: "DA/2341/2021",
        attributes: {
          address: ", NSW",
          description: "Construction of two storey dwelling house",
          info_url: "https://property.lakemac.com.au/ePathway/Productio...",
          date_scraped: "2021-09-10 02:05:17"
        }
      )
      CreateOrUpdateApplicationService.call(
        authority:,
        council_reference: "DA/2341/2021",
        attributes: {
          address: "1 Bank Street, CARDIFF NSW 2285",
          lat: -32.9456848,
          lng: 151.662601,
          suburb: "Cardiff",
          state: "NSW",
          postcode: "2285",
          description: "Dwelling House",
          info_url: "https://property.lakemac.com.au/ePathway/Productio...",
          date_scraped: "2021-09-14 02:04:04"
        }
      )
      expect(GeocodeService).to have_received(:call).with(", NSW")
      a = alert.recent_new_applications.first
      # This should pick up the location of the most recent version of the
      # application
      expect(a.location.lat).to eq(-32.9456848)
      expect(a.location.lng).to eq(151.662601)
    end
  end
end
