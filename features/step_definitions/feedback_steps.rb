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
  Then %{I should see "#{confirmed_comment_url(:id => comment.confirm_id, :host => 'dev.planningalerts.org.au')}" in the email body}
end
