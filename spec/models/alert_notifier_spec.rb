require 'spec_helper'

describe AlertNotifier do
  describe "when sending a planning alert" do
    before :each do
      @alert = Alert.create!(:email => "matthew@openaustralia.org", :address => "24 Bruce Rd, Glenbrook NSW 2773",
        :lat => 1.0, :lng => 2.0, :radius_meters => 800)
      @alert.stub!(:confirm_id).and_return("abcdef")
      @original_emails_sent = Stat.emails_sent
      @original_applications_sent = Stat.applications_sent
      @a1 = mock_model(Application, :address => "Foo Street, Bar", :council_reference => "a1", :description => "Knock something down", :id => 1)
      @a2 = mock_model(Application, :address => "Bar Street, Foo", :council_reference => "a2", :description => "Put something up", :id => 2)
      @email = AlertNotifier.create_alert(@alert, [@a1, @a2])
    end
    
    it "should be sent to the user's email address" do
      @email.to.should == [@alert.email]
    end
    
    it "should be from the main planningalerts email address" do
      @email.from.should == ["contact@planningalerts.org.au"]
      #@email.from_addrs.first.name.should == "PlanningAlerts.org.au"
    end
    
    it "should have a sensible subject line" do
      @email.subject.should == "Planning applications near #{@alert.address}"
    end
    
    it "should update the statistics" do
      Stat.emails_sent.should == @original_emails_sent + 1
      Stat.applications_sent.should == @original_applications_sent + 2
    end
    
    it "should update last_sent to the current time" do
      (Time.now - @alert.last_sent).abs.should < 1
    end
    
    it "should nicely format a list of multiple planning applications" do
      @email.body.should == <<-EOF
The following new planning applications have been found near 24 Bruce Rd, Glenbrook NSW 2773 within 800 m:

Foo Street, Bar (a1)

Knock something down

http://localhost:3000/applications/1?utm_medium=email&utm_source=alerts

-----------------------------

Bar Street, Foo (a2)

Put something up

http://localhost:3000/applications/2?utm_medium=email&utm_source=alerts

============================================================

PlanningAlerts.org.au is a free service run by the charity OpenAustralia Foundation.

You can subscribe to a geoRSS feed of applications for 24 Bruce Rd, Glenbrook NSW 2773 here: http://localhost:3000/applications.rss?address=24+Bruce+Rd%2C+Glenbrook+NSW+2773&radius=800

GeoRSS can be used to display planning applications on a map. For example, on Google Maps: http://maps.google.com.au/maps?q=http%3A%2F%2Flocalhost%3A3000%2Fapplications.rss%3Faddress%3D24%2BBruce%2BRd%252C%2BGlenbrook%2BNSW%2B2773%26radius%3D800

To change the size of the area covered by the alerts: http://localhost:3000/alerts/abcdef/area
To stop receiving these emails: http://localhost:3000/alerts/abcdef/unsubscribe
      EOF
    end
  end
end