require 'spec_helper'

describe UserNotifier, "when sending a new user confirmation email" do
  before :each do
    @user = mock("User", :email => "matthew@openaustralia.org", :confirm_id => "abcdef", :address => "24 Bruce Rd, Glenbrook NSW 2773")
    @email = UserNotifier.create_confirm(@user)
  end

  it "should be sent to the user's email address" do
    @email.to.should == [@user.email]
  end
  
  it "should be from the main planningalerts email address" do
    @email.from.should == ["contact@planningalerts.org.au"]
  end
  
  it "should say in the subject line it is an email to confirm a planning alert" do
    @email.subject.should == "Please confirm your planning alert"
  end
  
  it "should include a confirmation url" do
    @email.body.should include_text("http://www.planningalerts.org.au/confirmed.php?cid=abcdef")
  end
  
  it "should include the address for the alert" do
    @email.body.should include_text(@user.address)
  end
end