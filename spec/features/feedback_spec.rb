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

  scenario "Adding a comment" do
    authority = Factory(:authority, :full_name => "Foo", :email => "feedback@foo.gov.au")
    application = Factory(:application, :id => "1", :authority_id => authority.id)
    visit(application_path(application))

    fill_in("Comment", :with => "I think this is a really good ideas")
    fill_in("Name", :with => "Matthew Landauer")
    fill_in("Email", :with => "example@example.com")
    fill_in("Address", :with => "11 Foo Street")
    click_button("Create Comment")

    page.should have_content("Now check your email")
    page.should have_content("Click on the link in the email to confirm your comment")

    unread_emails_for("example@example.com").size.should == 1
    open_email("example@example.com")
    current_email.should have_subject("Please confirm your comment")
    # And the email body should contain a link to the confirmation page
    comment = Comment.find_by_text("I think this is a really good ideas")
    current_email.default_part_body.to_s.should include(confirmed_comment_url(:id => comment.confirm_id, :host => 'dev.planningalerts.org.au'))
  end

end