Given /^a planning authority "([^"]*)"( without a feedback email)?$/ do |authority_name, a|
  Factory(:authority, :full_name => authority_name)
end

Given /^a planning authority "([^"]*)" with a feedback email "([^"]*)"$/ do |authority_name, email|
  Factory(:authority, :full_name => authority_name, :email => email)
end

Given /^an application "([^"]*)" in planning authority "([^"]*)"$/ do |application_id, authority_name|
  authority = Authority.find_by_full_name(authority_name)
  Factory(:application, :id => application_id, :authority_id => authority.id)
end

Then /^the email body should contain a link to the confirmation page for the comment "([^"]*)"$/ do |text|
  comment = Comment.find_by_text(text)
  step %{I should see "#{confirmed_comment_url(:id => comment.confirm_id, :host => 'dev.planningalerts.org.au')}" in the email body}
end

Given /^an unconfirmed comment "([^"]*)" on application "([^"]*)"$/ do |comment, application_id|
  Factory(:comment, :confirmed => false, :text => comment, :application => Application.find(application_id))
end

Given /^a confirmed comment "([^"]*)" by "([^"]*)" with email "([^"]*)" and id "([^"]*)"$/ do |text, name, email, id|
  Factory(:comment, :confirmed => true, :text => text, :name => name, :email => email, :id => id)
end

Then /^I should see a link to application page "([^"]*)"$/ do |application_id|
  Then %{I should see "#{application_url(Application.find(application_id))}"}
end

Given /^a moderator email of "([^"]*)"$/ do |email|
  Kernel::silence_warnings { Configuration::EMAIL_MODERATOR = email }
end
