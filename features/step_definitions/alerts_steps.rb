When /^I fill in the email adress with "([^\"]*)"$/ do |value|
  fill_in("txtEmail", :with => value)
end

When /^I fill in the street address with "([^\"]*)"$/ do |value|
  fill_in("txtAddress", :with => value)
end

Then /^I should receive email alerts for the street address "([^\"]*)"$/ do |address|
  User.find(:first, :conditions => {:address => address, :email => current_email_address, :confirmed => true}).should_not be_nil
end
