require 'spec_helper'

feature "Manage alerts" do
  # In order to see new development applications in my suburb
  # I want to sign up for an email alert
  
  scenario "Sign up for email alert" do
    visit '/alerts/signup'

    fill_in("alert_email", :with => "example@example.com")
    fill_in("alert_address", :with => "24 Bruce Road, Glenbrook")
    click_button("Create alert")

    page.should have_content("Now check your email")

    unread_emails_for("example@example.com").size.should == 1
    open_email("example@example.com")
    current_email.should have_subject("Please confirm your planning alert")
    current_email.default_part_body.to_s.should include("24 Bruce Road, Glenbrook NSW 2773")
    click_first_link_in_email

    page.should have_content("your alert has been activated")
    page.should have_content("24 Bruce Road, Glenbrook NSW 2773")
    Alert.active.find(:first, :conditions => {:address => "24 Bruce Road, Glenbrook NSW 2773", :radius_meters => "2000", :email => current_email_address}).should_not be_nil
  end

  scenario "Unsubscribe from an email alert" do
    # Adding arbitrary coordinates so that geocoding is not carried out
    alert = Alert.create!(:address => "24 Bruce Rd, Glenbrook", :email => "example@example.com",
      :radius_meters => "2000", :lat => 1.0, :lng => 1.0, :confirmed => true)
    visit unsubscribe_alert_url(:id => alert.confirm_id)

    page.should have_content("You have been unsubscribed")
    page.should have_content("24 Bruce Rd, Glenbrook (within 2 km)")
    Alert.active.find(:first, :conditions => {:address => "24 Bruce Rd, Glenbrook",
      :email => "example@example.com"}).should be_nil
  end

  scenario "Change size of email alert" do
    alert = Alert.create!(:address => "24 Bruce Rd, Glenbrook", :email => "example@example.com",
      :radius_meters => "2000", :lat => 1.0, :lng => 1.0, :confirmed => true)
    visit area_alert_url(:id => alert.confirm_id)

    page.should have_content("What size area near 24 Bruce Rd, Glenbrook would you like to receive alerts for?")
    find_field("My suburb (within 2 km)")['checked'].should be_true
    choose("My neighbourhood (within 800 m)")
    click_button("Update size")

    page.should have_content("your alert size area has been updated")
    Alert.active.find(:first, :conditions => {:address => "24 Bruce Rd, Glenbrook", :radius_meters => "800", :email => "example@example.com"}).should_not be_nil
  end
end