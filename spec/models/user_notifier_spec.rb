require 'spec_helper'

describe UserNotifier do
  before :each do
    @user = User.create!(:email => "matthew@openaustralia.org", :address => "24 Bruce Rd, Glenbrook NSW 2773",
      :lat => 1.0, :lng => 2.0, :area_size_meters => 800)
    @user.stub!(:confirm_id).and_return("abcdef")
  end

  describe "when sending a new user confirmation email" do
    before :each do
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
      @email.body.should include_text("http://dev.planningalerts.org.au/confirmed.php?cid=abcdef")
    end
  
    it "should include the address for the alert" do
      @email.body.should include_text(@user.address)
    end
  end
  
  describe "when sending a planning alert" do
    before :each do
      @original_emails_sent = Stat.emails_sent
      @original_applications_sent = Stat.applications_sent
      @a1 = Application.new(:address => "Foo Street, Bar", :council_reference => "a1", :description => "Knock something down",
        :info_tinyurl => "tinyurl1", :map_url => "map1", :comment_tinyurl => "tinyurl2")
      @a2 = Application.new(:address => "Bar Street, Foo", :council_reference => "a2", :description => "Put something up",
        :info_tinyurl => "tinyurl3", :map_url => "map2", :comment_tinyurl => "tinyurl4")
      @email = UserNotifier.create_alert(@user, [@a1, @a2])
    end
    
    it "should be sent to the user's email address" do
      @email.to.should == [@user.email]
    end
    
    it "should be from the main planningalerts email address" do
      @email.from.should == ["contact@planningalerts.org.au"]
    end
    
    it "should have a sensible subject line" do
      @email.subject.should == "Planning applications near #{@user.address}"
    end
    
    it "should include the development application address and council id" do
      @email.body.should include_text("FOO STREET, BAR (A1)")
    end
    
    it "should include the description of the application" do
      @email.body.should include_text("Knock something down")
    end
    
    it "should include useful links for the application" do
      @email.body.should include_text("MORE INFORMATION: #{@a1.info_tinyurl}")
      @email.body.should include_text("MAP: #{@a1.map_url}")
      @email.body.should include_text("WHAT DO YOU THINK?: #{@a1.comment_tinyurl}")
    end
    
    it "should include a link to the georss feed" do
      @email.body.should include_text("http://dev.planningalerts.org.au/api.php?address=24+Bruce+Rd%2C+Glenbrook+NSW+2773&area_size=800&call=address")
    end
    
    it "should include a link to the maps version of the georss feed" do
      @email.body.should include_text("http://maps.google.com.au/maps?q=http%3A%2F%2Fdev.planningalerts.org.au%2Fapi.php%3Faddress%3D24%2BBruce%2BRd%252C%2BGlenbrook%2BNSW%2B2773%26area_size%3D800%26call%3Daddress")
    end
    
    it "should include a link to the unsubscribe url" do
      @email.body.should include_text("http://dev.planningalerts.org.au/unsubscribe.php?cid=abcdef")
    end
    
    it "should update the statistics" do
      Stat.emails_sent.should == @original_emails_sent + 1
      Stat.applications_sent.should == @original_applications_sent + 2
    end
    
    it "should update last_sent to the current time" do
      (Time.now - @user.last_sent).abs.should < 1e-2
    end
  end
end