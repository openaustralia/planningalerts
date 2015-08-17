require 'spec_helper'

describe Alert do
  before :each do
    @address = "24 Bruce Road, Glenbrook, NSW"
    @attributes = {email: "matthew@openaustralia.org", address: @address,
      radius_meters: 200}
    # Unless we override this elsewhere just stub the geocoder to return coordinates of address above
    @loc = Location.new(-33.772609, 150.624263)
    @loc.stub(:country_code).and_return("AU")
    @loc.stub(:full_address).and_return("24 Bruce Rd, Glenbrook NSW 2773")
    @loc.stub(:accuracy).and_return(8)
    @loc.stub(:all).and_return([@loc])
    Location.stub(:geocode).and_return(@loc)
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
    alerts.count.should == 1
    alerts.first.radius_meters.should == u2.radius_meters
  end
  
  it "should allow multiple alerts for different street addresses but the same email address" do
    email = "foo@foo.org"
    create(:alert, email: email, address: "A street address", radius_meters: 200, lat: 1.0, lng: 2.0)
    create(:alert, email: email, address: "Another street address", radius_meters: 800, lat: 1.0, lng: 2.0)
    Alert.where(email: email).count.should == 2
  end
  
  it "should be able to accept location information if it is already known and so not use the geocoder" do
    Location.should_not_receive(:geocode)
    @attributes[:lat] = 1.0
    @attributes[:lng] = 2.0
    u = create(:alert, @attributes)
    u.lat.should == 1.0
    u.lng.should == 2.0
  end
  
  describe "geocoding" do
    it "should happen automatically on saving" do
      alert = Alert.create!(@attributes)
      alert.lat.should == @loc.lat
      alert.lng.should == @loc.lng
      alert.should be_valid
    end
    
    it "should set an error on the address if there is an error on geocoding" do
      Location.stub(:geocode).and_return(double(error: "some error message", lat: nil, lng: nil, full_address: nil))
      u = Alert.new(email: "matthew@openaustralia.org")
      u.should_not be_valid
      u.errors[:address].should == ["some error message"]
    end
    
    it "should error if there are multiple matches from the geocoder" do
      Location.stub(:geocode).and_return(double(lat: 1, lng: 2, full_address: "Bruce Rd, VIC 3885", error: nil, all: [nil, nil]))
      u = Alert.new(address: "Bruce Road", email: "matthew@openaustralia.org")
      u.should_not be_valid
      u.errors[:address].should == ["isn't complete. Please enter a full street address, including suburb and state, e.g. Bruce Rd, VIC 3885"]
    end

    it "should replace the address with the full resolved address obtained by geocoding" do
      @attributes[:address] = "24 Bruce Road, Glenbrook"
      u = Alert.new(@attributes)
      u.save!
      u.address.should == "24 Bruce Rd, Glenbrook NSW 2773"
    end
  end

  describe "email address" do
    it "should be valid" do
      @attributes[:email] = "diddle@"
      u = Alert.new(@attributes)
      u.should_not be_valid
      u.errors[:email].should == ["does not appear to be valid"]    
    end

    it "should have an '@' in it" do
      @attributes[:email] = "diddle"
      u = Alert.new(@attributes)
      u.should_not be_valid
      u.errors[:email].should == ["does not appear to be valid"]    
    end
  end
  
  it "should be able to store the attribute location" do
    u = Alert.new
    u.location = Location.new(1.0, 2.0)
    u.lat.should == 1.0
    u.lng.should == 2.0
    u.location.lat.should == 1.0
    u.location.lng.should == 2.0
  end
  
  it "should handle location being nil" do
    u = Alert.new
    u.location = nil
    u.lat.should be_nil
    u.lng.should be_nil
    u.location.should be_nil
  end
  
  describe "radius_meters" do
    it "should have a number" do
      @attributes[:radius_meters] = "a"
      u = Alert.new(@attributes)
      u.should_not be_valid
      u.errors[:radius_meters].should == ["isn't selected"]
    end
  
    it "should be greater than zero" do
      @attributes[:radius_meters] = "0"
      u = Alert.new(@attributes)
      u.should_not be_valid
      u.errors[:radius_meters].should == ["isn't selected"]    
    end
  end

  describe "confirm_id" do
    it "should be a string" do
      u = Alert.create!(@attributes)
      u.confirm_id.should be_instance_of(String)
    end
  
    it "should not be the the same for two different users" do
      u1 = Alert.create!(@attributes)
      u2 = Alert.create!(@attributes)
      u1.confirm_id.should_not == u2.confirm_id
    end
    
    it "should only have hex characters in it and be exactly twenty characters long" do
      u = Alert.create!(@attributes)
      u.confirm_id.should =~ /^[0-9a-f]{20}$/
    end
  end
  
  describe "confirmed" do
    it "should be false when alert is created" do
      u = Alert.create!(@attributes)
      u.confirmed.should be_false
    end
    
    it "should be able to be set to false" do
      u = Alert.new(@attributes)
      u.confirmed = false
      u.save!
      u.confirmed.should == false
    end
    
    it "should be able to set to true" do
      u = Alert.new(@attributes)
      u.confirmed = true
      u.save!
      u.confirmed.should == true
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
      @alert.recent_applications.should have(3).items
      @alert.recent_applications.should include(@app1)
      @alert.recent_applications.should include(@app2)
      @alert.recent_applications.should include(@app3)
    end
    
    it "should return applications within the user's search area" do
      @alert.last_sent = 5.days.ago
      @alert.radius_meters = 500
      @alert.save!
      @alert.recent_applications.should have(2).items
      @alert.recent_applications.should include(@app2)
      @alert.recent_applications.should include(@app4)
    end
    
    it "should return applications that have been scraped in the last twenty four hours if the user has never had an alert" do
      @alert.last_sent = nil
      @alert.radius_meters = 2000
      @alert.save!
      @alert.recent_applications.should have(2).items
      @alert.recent_applications.should include(@app1)
      @alert.recent_applications.should include(@app2)      
    end
  end
  
  describe "frequency_distribution" do
    it "should return a frequency distribution of objects as an array sorted by count" do
      Alert.frequency_distribution(["a", "b", "c", "a", "a", "c", "a"]).should == [["a", 4], ["c", 2], ["b", 1]]
    end
  end
  
  describe "lga_name" do
    it "should return the local government authority name" do
      Geo2gov.should_receive(:new).with(1.0, 2.0).and_return(double(lga_name: "Blue Mountains"))

      a = create(:alert, lat: 1.0, lng: 2.0, email: "foo@bar.com", radius_meters: 200, address: "")
      a.lga_name.should == "Blue Mountains"      
    end
    
    it "should cache the value in the database" do
      Geo2gov.should_receive(:new).once.with(1.0, 2.0).and_return(double(lga_name: "Blue Mountains"))

      a = create(:alert, id: 1, lat: 1.0, lng: 2.0, email: "foo@bar.com", radius_meters: 200, address: "")
      a.lga_name.should == "Blue Mountains"
      b = Alert.first
      b.lga_name.should == "Blue Mountains"
    end
  end

  describe "comments" do
    it "should see a new comment when there is a new comments on an application" do
      alert = create(:alert, email: "matthew@openaustralia.org", address: @address, radius_meters: 2000)
      p1 = alert.location.endpoint(0, 501) # 501 m north of alert
      application = create(:application, lat: p1.lat, lng: p1.lng, suburb: "", state: "", postcode: "")
      comment1 = create(:comment, application: application, text: "This is a comment", name: "Matthew", email: "matthew@openaustralia.org", address: "Foo street", confirmed: true)
      alert.new_comments.should == [comment1]
    end

    it "should only see two new comments when there are two new comments on a single application" do
      alert = create(:alert, email: "matthew@openaustralia.org", address: @address, radius_meters: 2000)
      p1 = alert.location.endpoint(0, 501) # 501 m north of alert
      application = create(:application, lat: p1.lat, lng: p1.lng, suburb: "", state: "", postcode: "")
      comment1 = create(:comment, application: application, text: "This is a comment", name: "Matthew", email: "matthew@openaustralia.org", address: "Foo street", confirmed: true)
      comment2 = create(:comment, application: application, text: "This is a comment", name: "Matthew", email: "matthew@openaustralia.org", address: "Foo street", confirmed: true)
      alert.new_comments.should == [comment1, comment2]
    end
  end

  describe "#process!" do
    context "an alert with no new comments" do
      let(:alert) { Alert.create!(email: "matthew@openaustralia.org", address: @address, radius_meters: 2000) }
      before :each do
        alert.stub(:recent_comments).and_return([])
        # Don't know why this isn't cleared out automatically
        ActionMailer::Base.deliveries = []
      end

      context "and a new application nearby" do
        let(:application) do
          create(:application, lat: 1.0, lng: 2.0, address: "24 Bruce Road, Glenbrook, NSW",
            suburb: "Glenbrook", state: "NSW", postcode: "2773", no_alerted: 3)
        end

        before :each do
          alert.stub(:recent_applications).and_return([application])
        end

        it "should return the number of applications and comments sent" do
          alert.process!.should == [1, 0]
        end

        it "should send an email" do
          alert.process!
          ActionMailer::Base.deliveries.size.should == 1
        end

        it "should update the tally" do
          alert.process!
          application.no_alerted.should == 4
        end

        it "should update the last_sent time" do
          alert.process!
          (alert.last_sent - Time.now).abs.should < 1
        end

        it "should update the last_processed time" do
          alert.process!
          (alert.last_processed - Time.now).abs.should < 1
        end
      end

      context "and no new applications nearby" do
        before :each do
          alert.stub(:recent_applications).and_return([])
        end

        it "should not send an email" do
          alert.process!
          ActionMailer::Base.deliveries.should be_empty
        end

        it "should not update the last_sent time" do
          alert.process!
          alert.last_sent.should be_nil
        end

        it "should update the last_processed time" do
          alert.process!
          (alert.last_processed - Time.now).abs.should < 1
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
      it { expect(alert.email_has_several_other_alerts?).to be_false }
    end

    context "3 alerts or more" do
      before :each do
        create(:alert, confirmed: true, email: email)
      end

      it { expect(alert.email_has_several_other_alerts?).to be_true }
    end
  end

  describe "#expired_subscription?" do
    let(:email) { "luke@example.org" }
    let(:alert) { Alert.find_by(email: email) }

    before :each do
      2.times { create(:alert, confirmed: true, email: email) }
    end

    context "2 alerts" do
      it { expect(alert.expired_subscription?).to be_false }
    end

    context "3 alerts or more" do
      before :each do
        create(:alert, confirmed: true, email: email)
      end

      it { expect(alert.expired_subscription?).to be_false }

      context "trial subscription" do
        before { create(:subscription, email: email, trial_started_at: Date.today) }
        it { expect(alert.expired_subscription?).to be_false }
      end

      context "paid subscription" do
        before { create(:subscription, email: email, stripe_subscription_id: "a_stripe_id") }
        it { expect(alert.expired_subscription?).to be_false }
      end

      context "expired trial" do
        before { create(:subscription, email: email, trial_started_at: 7.days.ago) }
        it { expect(alert.expired_subscription?).to be_true }
      end
    end
  end
end
