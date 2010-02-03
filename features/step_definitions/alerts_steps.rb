Given /^I have received an email alert for "([^\"]*)" with a size of "([^\"]*)"$/ do |address, size|
  # Adding arbitrary coordinates so that geocoding is not carried out
  User.create!(:address => address, :email => current_email_address, :area_size_meters => size, :lat => 1.0, :lng => 1.0,
    :confirmed => true)
end

When /^I fill in the email adress with "([^\"]*)"$/ do |value|
  fill_in("txtEmail", :with => value)
end

When /^I fill in the street address with "([^\"]*)"$/ do |value|
  fill_in("txtAddress", :with => value)
end

When /^I click on the unsubscribe link in the email alert for "([^\"]*)"$/ do |address|
  u = User.find_by_address(address)
  visit url_for(:controller => :signup, :action => :unsubscribe, :cid => u.confirm_id)
end

Then /^I should receive email alerts for the street address "([^\"]*)"$/ do |address|
  User.find(:first, :conditions => {:address => address, :email => current_email_address, :confirmed => true}).should_not be_nil
end

Then /^I should not receive email alerts for the street address "([^\"]*)"$/ do |address|
  User.find(:first, :conditions => {:address => address, :email => current_email_address, :confirmed => true}).should be_nil
end