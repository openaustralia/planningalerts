require 'spec_helper'

describe EmailConfirmable::Notifier do
  describe "confirming an alert" do
    before :each do
      @alert = Alert.create!(:email => "matthew@openaustralia.org", :address => "24 Bruce Rd, Glenbrook NSW 2773",
        :lat => 1.0, :lng => 2.0, :radius_meters => 800)
      @alert.stub!(:confirm_id).and_return("abcdef")
      @email = EmailConfirmable::Notifier.create_confirm(@alert)
    end

    it "should be sent to the user's email address" do
      @email.to.should == [@alert.email]
    end
  
    it "should be from the main planningalerts email address" do
      @email.from.should == ["contact@planningalerts.org.au"]
      @email.from_addrs.first.name.should == "PlanningAlerts.org.au"
    end
  
    it "should say in the subject line it is an email to confirm a planning alert" do
      @email.subject.should == "Please confirm your planning alert"
    end
  
    it "should include a confirmation url" do
      @email.body.should include_text("http://dev.planningalerts.org.au/alerts/abcdef/confirmed")
    end
  
    it "should include the address for the alert" do
      @email.body.should include_text(@alert.address)
    end
  end
  
  describe "confirming a comment" do
    before :each do
      authority = mock_model(Authority, :full_name => "Foo Council", :email => "foo@bar.gov.au")
      application = mock_model(Application, :authority => authority, :address => "12 Foo Rd", :council_reference => "X/001", :description => "Building something", :id => 123)
      @comment = mock_model(Comment, :email => "foo@bar.com", :name => "Matthew", :application => application, :confirm_id => "abcdef", :text => "A good thing")
    end
    
    it "should be sent to the user's email address" do
      notifier = EmailConfirmable::Notifier.create_confirm(@comment)
      notifier.to.should == [@comment.email]
    end
  
    it "should be from the main planningalerts email address" do
      notifier = EmailConfirmable::Notifier.create_confirm(@comment)
      notifier.from.should == ["contact@planningalerts.org.au"]
      notifier.from_addrs.first.name.should == "PlanningAlerts.org.au"
    end
  
    it "should say in the subject line it is an email to confirm a comment" do
      notifier = EmailConfirmable::Notifier.create_confirm(@comment)
      notifier.subject.should == "Please confirm your comment"
    end
  
    it "should include a confirmation url" do
      notifier = EmailConfirmable::Notifier.create_confirm(@comment)
      notifier.body.should include_text("http://dev.planningalerts.org.au/comments/abcdef/confirmed")
    end
  end
  

end