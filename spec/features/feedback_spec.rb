require 'spec_helper'

# In order to affect the outcome of a development application
# As a citizen
# I want to send feedback on a development application directly to the planning authority

feature "Give feedback to Council" do
  scenario "Giving feedback for an authority without a feedback email" do
    authority = Factory(:authority, :full_name => "Foo")
    application = Factory(:application, :id => "1", :authority_id => authority.id)
    visit(application_path(application))

    page.should have_content("How to comment on this application")
  end
end