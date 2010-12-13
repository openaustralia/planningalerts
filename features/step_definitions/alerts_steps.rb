Given /^I have received an email alert for "([^\"]*)" with a size of "([^\"]*)"$/ do |address, size|
  # Adding arbitrary coordinates so that geocoding is not carried out
  Alert.create!(:address => address, :email => current_email_address, :radius_meters => size, :lat => 1.0, :lng => 1.0,
    :confirmed => true)
end

When /^I fill in the email adress with "([^\"]*)"$/ do |value|
  fill_in("alert_email", :with => value)
end

When /^I fill in the street address with "([^\"]*)"$/ do |value|
  fill_in("alert_address", :with => value)
end

When /^I click the "([^\"]*)" link in the email alert for "([^\"]*)"$/ do |link, address|
  alert = Alert.find_by_address(address)
  case link
  when "unsubscribe"
    visit unsubscribe_url(:cid => alert.confirm_id)
  when "change alert size"
    visit alert_area_url(:cid => alert.confirm_id)    
  else
    pending
  end
end

Then /^I should receive email alerts for the street address "([^\"]*)" with a size of "([^\"]*)"$/ do |address, size|
  Alert.find(:first, :conditions => {:address => address, :radius_meters => size, :email => current_email_address, :confirmed => true}).should_not be_nil
end

Then /^I should not receive email alerts for the street address "([^\"]*)"$/ do |address|
  Alert.find(:first, :conditions => {:address => address, :email => current_email_address, :confirmed => true}).should be_nil
end

Given /^the following email alerts:$/ do |table|
  table.hashes.each do |hash|
    Alert.create!(hash)
  end
end
