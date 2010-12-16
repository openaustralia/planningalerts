Given /^a planning authority "([^"]*)" without a feedback email$/ do |authority_name|
  Factory(:authority, :full_name => authority_name)
end

Given /^an application "([^"]*)" in planning authority "([^"]*)"$/ do |application_id, authority_name|
  authority = Authority.find_by_full_name(authority_name)
  Factory(:application, :id => application_id, :authority_id => authority.id)
end
