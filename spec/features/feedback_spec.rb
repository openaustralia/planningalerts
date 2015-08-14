require 'spec_helper'

feature "Give feedback to Council" do
  # In order to affect the outcome of a development application
  # As a citizen
  # I want to send feedback on a development application directly to the planning authority

  scenario "Giving feedback for an authority without a feedback email" do
    authority = create(:authority, full_name: "Foo")
    VCR.use_cassette('planningalerts') do
      application = create(:application, id: "1", authority_id: authority.id, comment_url: 'mailto:foo@bar.com')
      visit(application_path(application))
    end

    page.should have_content("How to comment on this application")
  end

  scenario "Hide feedback form where there is no feedback email or comment_url" do
    authority = create(:authority, full_name: "Foo")
    VCR.use_cassette('planningalerts') do
      application = create(:application, id: "1", authority_id: authority.id)
      visit(application_path(application))
    end

    page.should_not have_content("How to comment on this application")
  end

  scenario "Adding a comment" do
    authority = create(:authority, full_name: "Foo", email: "feedback@foo.gov.au")
    VCR.use_cassette('planningalerts') do
      application = create(:application, id: "1", authority_id: authority.id)
      visit(application_path(application))
    end

    fill_in("Comment", with: "I think this is a really good ideas")
    fill_in("Name", with: "Matthew Landauer")
    fill_in("Email", with: "example@example.com")
    fill_in("Address", with: "11 Foo Street")
    click_button("Create Comment")

    page.should have_content("Now check your email")
    page.should have_content("Click on the link in the email to confirm your comment")

    unread_emails_for("example@example.com").size.should == 1
    open_email("example@example.com")
    current_email.should have_subject("Please confirm your comment")
    # And the email body should contain a link to the confirmation page
    comment = Comment.find_by_text("I think this is a really good ideas")
    current_email.default_part_body.to_s.should include(confirmed_comment_url(id: comment.confirm_id, protocol: "https", host: 'dev.planningalerts.org.au'))
  end

  scenario "Unconfirmed comment should not be shown" do
    authority = create(:authority, full_name: "Foo", email: "feedback@foo.gov.au")
    VCR.use_cassette('planningalerts') do
      application = create(:application, id: "1", authority_id: authority.id)
      create(:comment, confirmed: false, text: "I think this is a really good ideas", application: application)
      visit(application_path(application))
    end

    page.should_not have_content("I think this is a really good ideas")
  end

  scenario "Confirming the comment" do
    authority = create(:authority, full_name: "Foo", email: "feedback@foo.gov.au")
    VCR.use_cassette('planningalerts') do
      application = create(:application, id: "1", authority_id: authority.id)
      comment = create(:comment, confirmed: false, text: "I think this is a really good ideas", application: application)
      visit(confirmed_comment_path(id: comment.confirm_id))
    end

    page.should have_content("Thanks. Your comment has been sent to Foo and is now visible on this page.")
    page.should have_content("I think this is a really good ideas")

    unread_emails_for("feedback@foo.gov.au").size.should == 1
    open_email("feedback@foo.gov.au")
    current_email.default_part_body.to_s.should include("I think this is a really good ideas")
  end

  scenario "Reporting abuse on a confirmed comment" do
    email_moderator = ::Configuration::EMAIL_MODERATOR
    Kernel::silence_warnings { ::Configuration::EMAIL_MODERATOR = "moderator@planningalerts.org.au" }
    VCR.use_cassette('planningalerts') do
      comment = create(:comment, confirmed: true, text: "I'm saying something abusive", name: "Jack Rude", email: "rude@foo.com", id: "23")
      visit(new_comment_report_path(comment))
    end

    fill_in("Your name", with: "Joe Reporter")
    fill_in("Your email", with: "reporter@foo.com")
    fill_in("Details", with: "You can't be rude to people!")
    click_button("Send report")

    page.should have_content("The comment has been reported and a moderator will look into it as soon as possible.")
    page.should have_content("Thanks for taking the time let us know about this.")

    unread_emails_for("moderator@planningalerts.org.au").size.should == 1
    open_email("moderator@planningalerts.org.au")
    current_email.should be_delivered_from("Joe Reporter <reporter@foo.com>")
    current_email.should have_subject("PlanningAlerts: Abuse report")

    Kernel::silence_warnings { ::Configuration::EMAIL_MODERATOR = email_moderator }
  end
end
