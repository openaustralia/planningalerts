# frozen_string_literal: true

require "spec_helper"

describe Alert do
  it_behaves_like "email_confirmable"

  let(:address) { "24 Bruce Road, Glenbrook" }

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

  it "should be able to accept location information if it is already known and so not use the geocoder" do
    expect(GoogleGeocodeService).not_to receive(:call)

    alert = create(:alert, lat: 1.0, lng: 2.0)

    expect(alert.lat).to eq(1.0)
    expect(alert.lng).to eq(2.0)
  end

  describe "geocoding" do
    before :each do
      expect(GoogleGeocodeService).to receive(:call).with(address).and_return(
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

    it "should happen automatically on saving" do
      alert = create(:alert, address: address, lat: nil, lng: nil)

      expect(alert.lat).to eq(-33.7726179)
      expect(alert.lng).to eq(150.6242341)
    end

    it "should replace the address with the full resolved address obtained by geocoding" do
      alert = create(:alert, address: "24 Bruce Road, Glenbrook", lat: nil, lng: nil)

      expect(alert.address).to eq("24 Bruce Rd, Glenbrook NSW 2773")
    end
  end

  it "should be able to store the attribute location" do
    alert = Alert.new
    alert.location = Location.new(lat: 1.0, lng: 2.0)
    expect(alert.lat).to eq(1.0)
    expect(alert.lng).to eq(2.0)
    expect(alert.location.lat).to eq(1.0)
    expect(alert.location.lng).to eq(2.0)
  end

  it "should handle location being nil" do
    alert = Alert.new
    alert.location = nil
    expect(alert.lat).to be_nil
    expect(alert.lng).to be_nil
    expect(alert.location).to be_nil
  end

  describe "radius_meters" do
    it "should have a number" do
      alert = build(:alert, radius_meters: "a")
      expect(alert).not_to be_valid
      expect(alert.errors[:radius_meters]).to eq(["isn't selected"])
    end

    it "should be greater than zero" do
      alert = build(:alert, radius_meters: "0")
      expect(alert).not_to be_valid
      expect(alert.errors[:radius_meters]).to eq(["isn't selected"])
    end
  end

  describe "confirmed" do
    it "should be false when alert is created" do
      expect(create(:alert).confirmed).to be false
    end

    it "should be able to be set to false" do
      alert = build(:alert)
      alert.confirmed = false
      alert.save!
      expect(alert.confirmed).to eq(false)
    end

    it "should be able to set to true" do
      alert = build(:alert)
      alert.confirmed = true
      alert.save!
      expect(alert.confirmed).to eq(true)
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
        expect(alert.location).to eq nil
      end
    end

    context "when the geocoder finds multiple locations" do
      it "doesn't update any values" do
        mock_geocoder_multiple_locations_response
        alert = build(:alert, address: original_address, lat: nil, lng: nil)

        alert.geocode_from_address

        expect(alert.address).to eq original_address
        expect(alert.location).to eq nil
      end
    end
  end

  describe "#geocoded?" do
    it { expect(build(:alert, address: "foo", lat: nil, lng: nil).geocoded?).to be false }
    it { expect(build(:alert, address: "foo", lat: 1, lng: 2).geocoded?).to be true }
  end

  describe "#unsubscribe!" do
    let(:alert) { create :alert }

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
    let(:alert) { create(:alert, last_sent: last_sent, radius_meters: radius_meters) }

    # Position test application around the point of the alert
    let(:p1) { alert.location.endpoint(0, 501) } # 501 m north of alert
    let(:p2) { alert.location.endpoint(0, 499) } # 499 m north of alert
    let(:p3) { alert.location.endpoint(45, 499 * Math.sqrt(2)) } # Just inside the NE corner of a box centred on the alert (of size 2 * 499m)
    let(:p4) { alert.location.endpoint(90, 499) } # 499 m east of alert

    let!(:app1) { create(:geocoded_application, lat: p1.lat, lng: p1.lng, date_scraped: 5.minutes.ago) }
    let!(:app2) { create(:geocoded_application, lat: p2.lat, lng: p2.lng, date_scraped: 12.hours.ago) }
    let!(:app3) { create(:geocoded_application, lat: p3.lat, lng: p3.lng, date_scraped: 2.days.ago) }
    let!(:app4) { create(:geocoded_application, lat: p4.lat, lng: p4.lng, date_scraped: 4.days.ago) }

    context "with a search radius which includes all applications" do
      let(:radius_meters) { 2000 }

      context "never before sent an alert" do
        let(:last_sent) { nil }

        it "should return applications that have been scraped in the last twenty four hours if the user has never had an alert" do
          expect(alert.recent_new_applications).to contain_exactly(app1, app2)
        end
      end

      context "last sent an alert 3 days ago" do
        let(:last_sent) { 3.days.ago }

        it "should return applications that have been scraped since the last time the user was sent an alert" do
          expect(alert.recent_new_applications).to contain_exactly(app1, app2, app3)
        end

        context "A couple of applications are updated one day ago" do
          before(:each) do
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

          it "should only include applications initially scraped within the last 3 days" do
            expect(alert.recent_new_applications).to contain_exactly(app1, app2, app3)
          end
        end

        context "One application has an updated location (way off in the distance)" do
          before(:each) do
            p = alert.location.endpoint(0, 10000)
            CreateOrUpdateApplicationService.call(
              authority: app2.authority,
              council_reference: app2.council_reference,
              attributes: {
                lat: p.lat,
                lng: p.lng
              }
            )
          end

          it "should not include the application with the updated address" do
            expect(alert.recent_new_applications).to contain_exactly(app1, app3)
          end
        end
      end

      context "last sent an alert 5 days ago" do
        let(:last_sent) { 5.days.ago }

        it "should return applications that have been scraped since the last time the user was sent an alert" do
          expect(alert.recent_new_applications).to contain_exactly(app1, app2, app3, app4)
        end
      end
    end

    context "with a reduced search radius of 500 metres" do
      let(:radius_meters) { 500 }

      # Using last_sent of 5 days ago to ensure that otherwise all applications
      # would be included if it wasn't for the search radius
      context "last sent an alert 5 days ago" do
        let(:last_sent) { 5.days.ago }

        it "should return applications within the user's search area" do
          expect(alert.recent_new_applications).to contain_exactly(app2, app4)
        end
      end
    end
  end

  describe "#new_comments" do
    let(:alert) { create(:alert, address: address, radius_meters: 2000) }
    let(:p1) { alert.location.endpoint(0, 501) } # 501 m north of alert
    let(:application) { create(:application, lat: p1.lat, lng: p1.lng, suburb: "", state: "", postcode: "") }

    it "sees a new comment when there are new comments on an application" do
      comment1 = create(:confirmed_comment, application: application)

      expect(alert.new_comments).to eql [comment1]
    end

    it "only sees two new comments when there are two new comments on a single application" do
      comment1 = create(:confirmed_comment, application: application)
      comment2 = create(:confirmed_comment, application: application)

      expect(alert.new_comments).to eql [comment1, comment2]
    end

    it "does not see old confirmed comments" do
      old_comment = create(:confirmed_comment,
                           confirmed_at: alert.cutoff_time - 1,
                           application: application)

      expect(alert.new_comments).to_not eql [old_comment]
    end

    it "does not see unconfirmed comments" do
      unconfirmed_comment = create(:unconfirmed_comment, application: application)

      expect(alert.new_comments).to_not eql [unconfirmed_comment]
    end

    it "does not see hidden comments" do
      hidden_comment = create(:confirmed_comment, hidden: true, application: application)

      expect(alert.new_comments).to_not eql [hidden_comment]
    end
  end

  describe "#new_replies" do
    let(:alert) do
      create(:alert,
             address: address,
             radius_meters: 2000,
             lat: 1.0,
             lng: 2.0)
    end

    context "when their are no new replies" do
      it { expect(alert.new_replies).to eq [] }
    end

    it "when there is a new reply on a nearby application it finds a new reply" do
      application = create(:application,
                           lat: 1.0,
                           lng: 2.0,
                           address: address,
                           suburb: "Glenbrook",
                           state: "NSW",
                           postcode: "2773",
                           no_alerted: 3)
      reply = create(:reply,
                     comment: create(:comment, application: application),
                     received_at: 1.hour.ago)

      expect(alert.new_replies).to eq [reply]
    end

    it "only finds two new reply when there are two new replies on a sinlge application" do
      application = create(:application,
                           lat: 1.0,
                           lng: 2.0,
                           address: address,
                           suburb: "Glenbrook",
                           state: "NSW",
                           postcode: "2773",
                           no_alerted: 3)
      reply1 = create(:reply,
                      comment: create(:comment, application: application),
                      received_at: 1.hour.ago)
      reply2 = create(:reply,
                      comment: create(:comment, application: application),
                      received_at: 2.hours.ago)

      expect(alert.new_replies).to eq [reply1, reply2]
    end
  end

  describe "#applications_with_new_comments" do
    let(:alert) { create(:alert, address: address, radius_meters: 2000, lat: 1.0, lng: 2.0) }
    let(:near_application) do
      create(:application,
             lat: 1.0,
             lng: 2.0,
             address: address,
             suburb: "Glenbrook",
             state: "NSW",
             postcode: "2773")
    end
    let(:far_away_application) do
      # 5001 m north of alert
      create(:application,
             lat: alert.location.endpoint(0, 5001).lat,
             lng: alert.location.endpoint(0, 5001).lng,
             address: address,
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

  describe "#applications_with_new_replies" do
    let(:alert) do
      create(:alert,
             address: address,
             radius_meters: 2000,
             lat: 1.0,
             lng: 2.0)
    end

    context "when there are no new relies near by" do
      it { expect(alert.applications_with_new_replies).to eq [] }
    end

    context "when there is a new reply near by" do
      it "should return the application it belongs to" do
        application = create(:application,
                             lat: 1.0,
                             lng: 2.0,
                             address: address,
                             suburb: "Glenbrook",
                             state: "NSW",
                             postcode: "2773",
                             no_alerted: 3)
        create(:reply,
               comment: create(:comment, application: application),
               received_at: 1.hour.ago)

        expect(alert.applications_with_new_replies).to eq [application]
      end
    end

    context "when there is a new reply far away" do
      it "should not return the application it belongs to" do
        far_away = alert.location.endpoint(0, 5001) # 5001 m north of alert
        application = create(:application,
                             lat: far_away.lat,
                             lng: far_away.lng,
                             address: address,
                             suburb: "Glenbrook",
                             state: "NSW",
                             postcode: "2773",
                             no_alerted: 3)
        create(:reply,
               comment: create(:comment, application: application),
               received_at: 1.hour.ago)

        expect(alert.applications_with_new_replies).to eq []
      end
    end
  end
end
