require 'spec_helper'

describe Alert do
  it_behaves_like "email_confirmable"

  before :each do
    @address = "24 Bruce Road, Glenbrook, NSW"
    @attributes = {email: "matthew@openaustralia.org", address: @address,
      radius_meters: 200}
    # Unless we override this elsewhere just stub the geocoder to return coordinates of address above
    @loc = Location.new(-33.772609, 150.624263)
    allow(@loc).to receive(:country_code).and_return("AU")
    allow(@loc).to receive(:full_address).and_return("24 Bruce Rd, Glenbrook NSW 2773")
    allow(@loc).to receive(:accuracy).and_return(8)
    allow(@loc).to receive(:all).and_return([@loc])
    allow(Location).to receive(:geocode).and_return(@loc)
    Alert.delete_all
  end

  it "should have no trouble creating a user with valid attributes" do
    Alert.create!(@attributes)
  end

  # In order to stop frustrating multiple alerts
  it "should only have one alert active for a particular street address / email address combination at one time" do
    email = "foo@foo.org"
    u1 = Alert.create!(email: email, address: "A street address", radius_meters: 200, lat: 1.0, lng: 2.0)
    u2 = Alert.create!(email: email, address: "A street address", radius_meters: 800, lat: 1.0, lng: 2.0)
    alerts = Alert.where(email: email)
    expect(alerts.count).to eq(1)
    expect(alerts.first.radius_meters).to eq(u2.radius_meters)
  end

  it "should allow multiple alerts for different street addresses but the same email address" do
    email = "foo@foo.org"
    create(:alert, email: email, address: "A street address", radius_meters: 200, lat: 1.0, lng: 2.0)
    create(:alert, email: email, address: "Another street address", radius_meters: 800, lat: 1.0, lng: 2.0)
    expect(Alert.where(email: email).count).to eq(2)
  end

  it "should be able to accept location information if it is already known and so not use the geocoder" do
    expect(Location).not_to receive(:geocode)
    @attributes[:lat] = 1.0
    @attributes[:lng] = 2.0
    u = create(:alert, @attributes)
    expect(u.lat).to eq(1.0)
    expect(u.lng).to eq(2.0)
  end

  describe "geocoding" do
    it "should happen automatically on saving" do
      alert = Alert.create!(@attributes)
      expect(alert.lat).to eq(@loc.lat)
      expect(alert.lng).to eq(@loc.lng)
      expect(alert).to be_valid
    end

    it "should set an error on the address if there is an error on geocoding" do
      allow(Location).to receive(:geocode).and_return(double(error: "some error message", lat: nil, lng: nil, full_address: nil))
      u = Alert.new(email: "matthew@openaustralia.org")
      expect(u).not_to be_valid
      expect(u.errors[:address]).to eq(["some error message"])
    end

    it "should error if there are multiple matches from the geocoder" do
      allow(Location).to receive(:geocode).and_return(double(lat: 1, lng: 2, full_address: "Bruce Rd, VIC 3885", error: nil, all: [nil, nil]))
      u = Alert.new(address: "Bruce Road", email: "matthew@openaustralia.org")
      expect(u).not_to be_valid
      expect(u.errors[:address]).to eq(["isn't complete. Please enter a full street address, including suburb and state, e.g. Bruce Rd, VIC 3885"])
    end

    it "should replace the address with the full resolved address obtained by geocoding" do
      @attributes[:address] = "24 Bruce Road, Glenbrook"
      u = Alert.new(@attributes)
      u.save!
      expect(u.address).to eq("24 Bruce Rd, Glenbrook NSW 2773")
    end
  end

  describe "email address" do
    it "is not blank" do
      @attributes[:email] = "  "
      expect(Alert.new(@attributes)).to_not be_valid
    end

    it "should be valid" do
      @attributes[:email] = "diddle@"
      u = Alert.new(@attributes)
      expect(u).not_to be_valid
      expect(u.errors[:email]).to eq(["does not appear to be a valid e-mail address"])
    end

    it "should have an '@' in it" do
      @attributes[:email] = "diddle"
      u = Alert.new(@attributes)
      expect(u).not_to be_valid
      expect(u.errors[:email]).to eq(["does not appear to be a valid e-mail address"])
    end
  end

  it "should be able to store the attribute location" do
    u = Alert.new
    u.location = Location.new(1.0, 2.0)
    expect(u.lat).to eq(1.0)
    expect(u.lng).to eq(2.0)
    expect(u.location.lat).to eq(1.0)
    expect(u.location.lng).to eq(2.0)
  end

  it "should handle location being nil" do
    u = Alert.new
    u.location = nil
    expect(u.lat).to be_nil
    expect(u.lng).to be_nil
    expect(u.location).to be_nil
  end

  describe "radius_meters" do
    it "should have a number" do
      @attributes[:radius_meters] = "a"
      u = Alert.new(@attributes)
      expect(u).not_to be_valid
      expect(u.errors[:radius_meters]).to eq(["isn't selected"])
    end

    it "should be greater than zero" do
      @attributes[:radius_meters] = "0"
      u = Alert.new(@attributes)
      expect(u).not_to be_valid
      expect(u.errors[:radius_meters]).to eq(["isn't selected"])
    end
  end

  describe "confirm_id" do
    it "should be a string" do
      u = Alert.create!(@attributes)
      expect(u.confirm_id).to be_instance_of(String)
    end

    it "should not be the the same for two different users" do
      u1 = Alert.create!(@attributes)
      u2 = Alert.create!(@attributes)
      expect(u1.confirm_id).not_to eq(u2.confirm_id)
    end

    it "should only have hex characters in it and be exactly twenty characters long" do
      u = Alert.create!(@attributes)
      expect(u.confirm_id).to match(/^[0-9a-f]{20}$/)
    end
  end

  describe "confirmed" do
    it "should be false when alert is created" do
      u = Alert.create!(@attributes)
      expect(u.confirmed).to be_falsey
    end

    it "should be able to be set to false" do
      u = Alert.new(@attributes)
      u.confirmed = false
      u.save!
      expect(u.confirmed).to eq(false)
    end

    it "should be able to set to true" do
      u = Alert.new(@attributes)
      u.confirmed = true
      u.save!
      expect(u.confirmed).to eq(true)
    end
  end

  describe ".count_of_new_unique_email_created_on_date" do
    it { expect(Alert.count_of_new_unique_email_created_on_date("2016-08-24")).to eq 0 }

    context "when there are unconfirmed alerts" do
      before do
        create(:unconfirmed_alert, created_at: "2016-08-24")
      end

      it "it doesn't include them" do
        expect(Alert.count_of_new_unique_email_created_on_date("2016-08-24")).to eq 0
      end
    end

    context "when there are active alerts not created on this day" do
      before do
        create(:confirmed_alert, created_at: "2016-08-22")
      end

      it "doesn't include them" do
        expect(Alert.count_of_new_unique_email_created_on_date("2016-08-24")).to eq 0
      end
    end

    context "when there are active alerts created on this day with emails that have previously created alerts" do
      before do
        create(:confirmed_alert, email: "clare@jones.org", created_at: "2016-08-24")
        create(:confirmed_alert, email: "clare@jones.org", created_at: "2016-06-16")
      end

      it "doesn't include them" do
        expect(Alert.count_of_new_unique_email_created_on_date("2016-08-24")).to eq 0
      end
    end

    context "when there are active alerts create on this day" do
      before do
        @alert =  create(:confirmed_alert, email: "1@example.org", created_at: Time.new(2016, 8, 24, 7, 0, 0, 00))
        @alert2 =  create(:confirmed_alert, email: "2@example.org", created_at: Time.new(2016, 8, 24, 12, 0, 0, 00))
        @alert3 =  create(:confirmed_alert, email: "3@example.org", created_at: Time.new(2012, 4, 01, 9, 0, 0, 00))
        @alert4 =  create(:confirmed_alert, email: "4@example.org" ,created_at: Time.new(1990, 5, 27, 21, 0, 0, 00))
      end

      it "includes them" do
        expect(Alert.count_of_new_unique_email_created_on_date("2016-08-24")).to eq 2
        expect(Alert.count_of_new_unique_email_created_on_date("2012-04-01")).to eq 1
        expect(Alert.count_of_new_unique_email_created_on_date("1990-05-27")).to eq 1
      end
    end

    context "when there are multiple active alerts created with the same email on this day" do
      before do
        @alert1 = create(:confirmed_alert, email: "clare@jones.org", created_at: "2016-08-24")
        @alert2 = create(:confirmed_alert, email: "clare@jones.org", created_at: "2016-08-24")
      end

      it "only counts one" do
        expect(Alert.count_of_new_unique_email_created_on_date("2016-08-24")).to eq 1
      end
    end

    context "when the alert has since been unsubscribed" do
      let!(:alert) do
        a = Timecop.freeze(Date.new(2016, 8, 24)) do
          create :confirmed_alert
        end

        Timecop.freeze(Date.new(2016, 8, 24)) do
          a.unsubscribe!
        end

        a
      end

      it "still includes it for the day it was created" do
        expect(Alert.count_of_new_unique_email_created_on_date("2016-08-24")).to eq 1
      end
    end
  end

  describe ".count_of_email_completely_unsubscribed_on_date" do
    it "is 0 when there is no unsubscribes" do
      expect(Alert.count_of_email_completely_unsubscribed_on_date(Date.today)).to eql 0
    end

    it "is 0 when there is no complete unsubscribes" do
      create(:unsubscribed_alert, email: "foo@email.com")
      create(:unsubscribed_alert, email: "foo@email.com")
      create(:confirmed_alert, email: "foo@email.com")

      expect(Alert.count_of_email_completely_unsubscribed_on_date(Date.today)).to eql 0
    end

    it "only counts unique emails" do
      Timecop.freeze(Time.utc(2016, 8, 23)) do
        create(:unsubscribed_alert, email: "foo@email.com", unsubscribed_at: Time.now)
        create(:unsubscribed_alert, email: "foo@email.com", unsubscribed_at: Time.now)
      end

      expect(Alert.count_of_email_completely_unsubscribed_on_date(Date.new(2016, 8, 23))).to eql 1
    end

    it "only counts unsubscribes on the specified date" do
      alert1 = create(:confirmed_alert, email: "foo@email.com")
      alert2 = create(:confirmed_alert, email: "bar@email.com")

      Timecop.freeze(Time.utc(2016, 8, 23)) { alert1.unsubscribe! }
      Timecop.freeze(Time.utc(2016, 8, 24)) { alert2.unsubscribe! }

      expect(Alert.count_of_email_completely_unsubscribed_on_date(Date.new(2016, 8, 23))).to eql 1
    end

    context "when someone completely unsubscribes and then resubscribes" do
      before do
        alert = Timecop.freeze(Time.utc(2016, 8, 20)) do
          create(:confirmed_alert, email: "foo@email.com")
        end

        Timecop.freeze(Time.utc(2016, 8, 23)) { alert.unsubscribe! }

        Timecop.freeze(Time.utc(2016, 8, 28)) do
          create(:confirmed_alert, email: "foo@email.com")
        end
      end

      it "counts their complete unsubscribe" do
        expect(Alert.count_of_email_completely_unsubscribed_on_date(Date.new(2016, 8, 23))).to eql 1
      end

      context "and then unsubscribe but not completely" do
        before do
          alert = Timecop.freeze(Time.utc(2016, 8, 28)) do
            create(:confirmed_alert, email: "foo@email.com")
          end

          Timecop.freeze(Time.utc(2016, 9, 1)) { alert.unsubscribe! }
        end

        it "doesn't count their unsubscribe" do
          expect(Alert.count_of_email_completely_unsubscribed_on_date(Date.new(2016, 9, 1))).to eql 0
        end
      end
    end
  end

  describe "#unsubscribe!" do
    let(:alert) { create :alert }

    it "unsubscribes the alert" do
      alert.unsubscribe!

      expect(alert).to be_unsubscribed
    end

    it "sets the unsubscribed_at time" do
      action_time = Time.new(2016, 11, 3, 15, 29)

      Timecop.freeze(action_time) { alert.unsubscribe! }

      expect(alert.unsubscribed_at).to eql action_time
    end
  end

  describe "#address_for_placeholder" do
    it "has a default address" do
      expect(Alert.new.address_for_placeholder).to eql "1 Sowerby St, Goulburn, NSW 2580"
    end

    it "can be set to something else" do
      expect(
        Alert.new(
          address_for_placeholder: "5 Boaty St, Boat Face"
        ).address_for_placeholder
     ).to eql "5 Boaty St, Boat Face"
    end
  end

  describe "recent applications for this user" do
    before :each do
      @alert = Alert.create!(email: "matthew@openaustralia.org", address: @address, radius_meters: 2000)
      # Position test application around the point of the alert
      p1 = @alert.location.endpoint(0, 501) # 501 m north of alert
      p2 = @alert.location.endpoint(0, 499) # 499 m north of alert
      p3 = @alert.location.endpoint(45, 499 * Math.sqrt(2)) # Just inside the NE corner of a box centred on the alert (of size 2 * 499m)
      p4 = @alert.location.endpoint(90, 499) # 499 m east of alert
      auth = create(:authority)
      @app1 = create(:application, lat: p1.lat, lng: p1.lng, date_scraped: 5.minutes.ago, council_reference: "A1", suburb: "", state: "", postcode: "", authority: auth)
      @app2 = create(:application, lat: p2.lat, lng: p2.lng, date_scraped: 12.hours.ago, council_reference: "A2", suburb: "", state: "", postcode: "", authority: auth)
      @app3 = create(:application, lat: p3.lat, lng: p3.lng, date_scraped: 2.days.ago, council_reference: "A3", suburb: "", state: "", postcode: "", authority: auth)
      @app4 = create(:application, lat: p4.lat, lng: p4.lng, date_scraped: 4.days.ago, council_reference: "A4", suburb: "", state: "", postcode: "", authority: auth)
    end

    it "should return applications that have been scraped since the last time the user was sent an alert" do
      @alert.last_sent = 3.days.ago
      @alert.radius_meters = 2000
      @alert.save!

      expect(@alert.recent_applications.size).to eq 3
      expect(@alert.recent_applications).to include(@app1)
      expect(@alert.recent_applications).to include(@app2)
      expect(@alert.recent_applications).to include(@app3)
    end

    it "should return applications within the user's search area" do
      @alert.last_sent = 5.days.ago
      @alert.radius_meters = 500
      @alert.save!

      expect(@alert.recent_applications.size).to eq 2
      expect(@alert.recent_applications).to include(@app2)
      expect(@alert.recent_applications).to include(@app4)
    end

    it "should return applications that have been scraped in the last twenty four hours if the user has never had an alert" do
      @alert.last_sent = nil
      @alert.radius_meters = 2000
      @alert.save!

      expect(@alert.recent_applications.size).to eq 2
      expect(@alert.recent_applications).to include(@app1)
      expect(@alert.recent_applications).to include(@app2)
    end
  end

  describe "frequency_distribution" do
    it "should return a frequency distribution of objects as an array sorted by count" do
      expect(Alert.frequency_distribution(["a", "b", "c", "a", "a", "c", "a"])).to eq([["a", 4], ["c", 2], ["b", 1]])
    end
  end

  describe "lga_name" do
    it "should return the local government authority name" do
      expect(Geo2gov).to receive(:new).with(1.0, 2.0).and_return(double(lga_name: "Blue Mountains"))

      a = create(:alert, lat: 1.0, lng: 2.0, email: "foo@bar.com", radius_meters: 200, address: "")
      expect(a.lga_name).to eq("Blue Mountains")
    end

    it "should cache the value in the database" do
      expect(Geo2gov).to receive(:new).once.with(1.0, 2.0).and_return(double(lga_name: "Blue Mountains"))

      a = create(:alert, id: 1, lat: 1.0, lng: 2.0, email: "foo@bar.com", radius_meters: 200, address: "")
      expect(a.lga_name).to eq("Blue Mountains")
      b = Alert.first
      expect(b.lga_name).to eq("Blue Mountains")
    end
  end

  describe "#new_comments" do
    let(:alert) { create(:alert, address: @address, radius_meters: 2000) }
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
    let (:alert) do
      create(:alert,
             address: @address,
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
                            address: @address,
                            suburb: "Glenbrook",
                            state: "NSW",
                            postcode: "2773",
                            no_alerted: 3)
      reply = create(:reply,
                      comment: create(:comment, application: application),
                      received_at: 1.hours.ago)

      expect(alert.new_replies).to eq [reply]
    end

    it "only finds two new reply when there are two new replies on a sinlge application" do
      application = create(:application,
                            lat: 1.0,
                            lng: 2.0,
                            address: @address,
                            suburb: "Glenbrook",
                            state: "NSW",
                            postcode: "2773",
                            no_alerted: 3)
      reply1 = create(:reply,
                      comment: create(:comment, application: application),
                      received_at: 1.hours.ago)
      reply2 = create(:reply,
                      comment: create(:comment, application: application),
                      received_at: 2.hours.ago)

      expect(alert.new_replies).to eq [reply1, reply2]
    end
  end

  describe "#applications_with_new_comments" do
    let (:alert) { create(:alert, address: @address, radius_meters: 2000, lat: 1.0, lng: 2.0) }
    let (:near_application) do
      create(:application,
             lat: 1.0,
             lng: 2.0,
             address: @address,
             suburb: "Glenbrook",
             state: "NSW",
             postcode: "2773")
    end
    let (:far_away_application) do
      # 5001 m north of alert
      create(:application,
             lat: alert.location.endpoint(0, 5001).lat,
             lng: alert.location.endpoint(0, 5001).lng,
             address: @address,
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
    let (:alert) do
      create(:alert,
             address: @address,
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
                             address: @address,
                             suburb: "Glenbrook",
                             state: "NSW",
                             postcode: "2773",
                             no_alerted: 3)
        create(:reply,
               comment: create(:comment, application: application),
               received_at: 1.hours.ago)

        expect(alert.applications_with_new_replies).to eq [application]
      end
    end

    context "when there is a new reply far away" do
      it "should not return the application it belongs to" do
        far_away = alert.location.endpoint(0, 5001) # 5001 m north of alert
        application = create(:application,
                             lat: far_away.lat,
                             lng: far_away.lng,
                             address: @address,
                             suburb: "Glenbrook",
                             state: "NSW",
                             postcode: "2773",
                             no_alerted: 3)
        create(:reply,
               comment: create(:comment, application: application),
               received_at: 1.hours.ago)

        expect(alert.applications_with_new_replies).to eq []
      end
    end
  end

  describe "#process!" do
    context "an alert with no new comments" do
      let(:alert) { Alert.create!(email: "matthew@openaustralia.org", address: @address, radius_meters: 2000) }
      before :each do
        allow(alert).to receive(:recent_comments).and_return([])
        # Don't know why this isn't cleared out automatically
        ActionMailer::Base.deliveries = []
      end

      context "and a new application nearby" do
        let(:application) do
          create(:application, lat: 1.0, lng: 2.0, address: "24 Bruce Road, Glenbrook, NSW",
            suburb: "Glenbrook", state: "NSW", postcode: "2773", no_alerted: 3)
        end

        before :each do
          allow(alert).to receive(:recent_applications).and_return([application])
        end

        it "should return the number of applications, comments and replies sent" do
          expect(alert.process!).to eq([1, 0, 0])
        end

        it "should send an email" do
          alert.process!
          expect(ActionMailer::Base.deliveries.size).to eq(1)
        end

        it "should update the tally" do
          alert.process!
          expect(application.no_alerted).to eq(4)
        end

        it "should update the last_sent time" do
          alert.process!
          expect((alert.last_sent - Time.now).abs).to be < 1
        end

        it "should update the last_processed time" do
          alert.process!
          expect((alert.last_processed - Time.now).abs).to be < 1
        end
      end

      context "and no new applications nearby" do
        before :each do
          allow(alert).to receive(:recent_applications).and_return([])
        end

        it "should not send an email" do
          alert.process!
          expect(ActionMailer::Base.deliveries).to be_empty
        end

        it "should not update the last_sent time" do
          alert.process!
          expect(alert.last_sent).to be_nil
        end

        it "should update the last_processed time" do
          alert.process!
          expect((alert.last_processed - Time.now).abs).to be < 1
        end
      end

      context "and one new reply nearby" do
        let(:application) do
          create(:application,
                 lat: 1.0,
                 lng: 2.0,
                 address: "24 Bruce Road, Glenbrook, NSW",
                 suburb: "Glenbrook",
                 state: "NSW",
                 postcode: "2773",
                 no_alerted: 3)
        end
        let(:reply) { create(:reply,
                             comment: create(:comment, application: application),
                             received_at: 1.hours.ago) }

        before :each do
          allow(alert).to receive(:new_replies).and_return([reply])
        end

        it "should return the number of applications, comments and replies sent" do
          expect(alert.process!).to eq([0, 0, 1])
        end

        it "should send an email" do
          alert.process!
          expect(ActionMailer::Base.deliveries.size).to eq(1)
        end
      end
    end
  end

  describe "#email_has_several_other_alerts?" do
    let(:email) { "luke@example.org" }
    let(:alert) { Alert.find_by(email: email) }

    before :each do
      2.times { create(:alert, confirmed: true, email: email) }
    end

    context "2 alerts" do
      it { expect(alert.email_has_several_other_alerts?).to be false }
    end

    context "3 alerts or more" do
      before :each do
        create(:alert, confirmed: true, email: email)
      end

      it { expect(alert.email_has_several_other_alerts?).to be true }
    end
  end

  describe "#expired_subscription?" do
    let(:email) { "luke@example.org" }
    let(:alert) { Alert.find_by(email: email) }

    before :each do
      2.times { create(:alert, confirmed: true, email: email) }
    end

    context "2 alerts" do
      it { expect(alert.expired_subscription?).to be false }
    end

    context "3 alerts or more" do
      before :each do
        create(:alert, confirmed: true, email: email)
      end

      it { expect(alert.expired_subscription?).to be_falsey }

      context "trial subscription" do
        before { create(:subscription, email: email, trial_started_at: Date.today) }
        it { expect(alert.expired_subscription?).to be false }
      end

      context "paid subscription" do
        before { create(:subscription, email: email, stripe_subscription_id: "a_stripe_id") }
        it { expect(alert.expired_subscription?).to be false }
      end

      context "expired trial" do
        before { create(:subscription, email: email, trial_started_at: 7.days.ago) }
        it { expect(alert.expired_subscription?).to be true }
      end
    end
  end
end
