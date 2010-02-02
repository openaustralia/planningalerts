When /^I fill in the email adress with "([^\"]*)"$/ do |value|
  fill_in("txtEmail", :with => value)
end

When /^I fill in the street address with "([^\"]*)"$/ do |value|
  fill_in("txtAddress", :with => value)
end

Then /^I should receive an email$/ do
  pending
end