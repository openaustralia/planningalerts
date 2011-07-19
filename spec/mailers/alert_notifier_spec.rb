require 'spec_helper'

describe AlertNotifier do
  before :each do
    @alert = Alert.create!(:email => "matthew@openaustralia.org", :address => "24 Bruce Rd, Glenbrook NSW 2773",
      :lat => 1.0, :lng => 2.0, :radius_meters => 800)
    @alert.stub!(:confirm_id).and_return("abcdef")
    @original_emails_sent = Stat.emails_sent
    @original_applications_sent = Stat.applications_sent
    @a1 = mock_model(Application, :address => "Foo Street, Bar", :council_reference => "a1", :description => "Knock something down", :id => 1)
    @a2 = mock_model(Application, :address => "Bar Street, Foo", :council_reference => "a2", :description => "Put something up", :id => 2)
  end

  describe "when sending a planning alert with one new planning application" do
    before :each do
      @email = AlertNotifier.alert(@alert, [@a1])
    end

    it "should use the singular (application) in the subject line" do
      @email.subject.should == "1 new planning application near #{@alert.address}"
    end
  end
  
  describe "when sending a planning alert with two new planning applications" do
    before :each do
      @email = AlertNotifier.alert(@alert, [@a1, @a2])
    end
    
    it "should be sent to the user's email address" do
      @email.to.should == [@alert.email]
    end
    
    it "should be from the main planningalerts email address" do
      @email.from.should == ["contact@planningalerts.org.au"]
      #@email.from_addrs.first.name.should == "PlanningAlerts.org.au"
    end
    
    it "should have a sensible subject line" do
      @email.subject.should == "2 new planning applications near #{@alert.address}"
    end
    
    it "should update the statistics" do
      Stat.emails_sent.should == @original_emails_sent + 1
      Stat.applications_sent.should == @original_applications_sent + 2
    end
    
    it "should update last_sent to the current time" do
      (Time.now - @alert.last_sent).abs.should < 1
    end
    
    it "should nicely format a list of multiple planning applications" do
      @email.body.to_s.should == <<-EOF
The following new planning applications have been found near 24 Bruce Rd, Glenbrook NSW 2773 within 800 m:

Foo Street, Bar

Knock something down

http://dev.planningalerts.org.au/applications/1?utm_medium=email&utm_source=alerts

-----------------------------

Bar Street, Foo

Put something up

http://dev.planningalerts.org.au/applications/2?utm_medium=email&utm_source=alerts

============================================================

PlanningAlerts.org.au is a free service run by the charity OpenAustralia Foundation.
This service depends on donations from people like you for its survival.
If you use this service please consider donating: http://www.openaustraliafoundation.org.au/donate/?utm_medium=email&utm_source=alerts

To change the size of the area covered by the alerts: http://dev.planningalerts.org.au/alerts/abcdef/area

To stop receiving these emails: http://dev.planningalerts.org.au/alerts/abcdef/unsubscribe
      EOF
    end
  end
end