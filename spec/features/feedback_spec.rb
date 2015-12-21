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

  scenario "Getting an error message if the comment form isn’t completed correctly" do
    authority = create(:authority, full_name: "Foo", email: "feedback@foo.gov.au")
    VCR.use_cassette('planningalerts') do
      application = create(:application, id: "1", authority_id: authority.id)
      visit(application_path(application))
    end

    fill_in("Have your say on this application", with: "I think this is a really good idea")
    fill_in("Your name", with: "Matthew Landauer")
    fill_in("Your email", with: "example@example.com")
    # Don't fill in the address
    click_button("Post your public comment")

    page.should have_content("Some of the comment wasn't filled out completely. See below.")
    page.should_not have_content("Now check your email")
  end

  scenario "Adding a comment" do
    authority = create(:authority, full_name: "Foo", email: "feedback@foo.gov.au")
    VCR.use_cassette('planningalerts') do
      application = create(:application, id: "1", authority_id: authority.id)
      visit(application_path(application))
    end

    fill_in("Have your say on this application", with: "I think this is a really good ideas")
    fill_in("Your name", with: "Matthew Landauer")
    fill_in("Your email", with: "example@example.com")
    fill_in("Your street address", with: "11 Foo Street")
    click_button("Post your public comment")

    page.should have_content("Now check your email")
    page.should have_content("Click on the link in the email to confirm your comment")

    unread_emails_for("example@example.com").size.should == 1
    open_email("example@example.com")
    current_email.should have_subject("Please confirm your comment")
    # And the email body should contain a link to the confirmation page
    comment = Comment.find_by_text("I think this is a really good ideas")
    current_email.default_part_body.to_s.should include(confirmed_comment_url(id: comment.confirm_id, protocol: "https", host: 'dev.planningalerts.org.au'))
  end

  context "when there is the option to write to a councillor" do
    given(:application) do
      VCR.use_cassette('planningalerts') do
        create(:application, id: "1", authority: create(:contactable_authority))
      end
    end

    around do |test|
      with_modified_env COUNCILLORS_ENABLED: 'true' do
        test.run
      end
    end

    background do
      create(:councillor, authority: application.authority)
    end

    scenario "Adding a comment for the planning authority" do
      visit(application_path(application))

      expect(page).to have_content("Who should this go to?")

      fill_in("Have your say on this application", with: "I think this is a really good ideas")
      fill_in("Your name", with: "Matthew Landauer")
      choose("The planning authority")
      fill_in("Your email", with: "example@example.com")
      fill_in("Your street address", with: "11 Foo Street")
      click_button("Post your public comment")

      expect(page).to have_content("Now check your email")
      expect(page).to have_content("Click on the link in the email to confirm your comment")

      expect(unread_emails_for("example@example.com").size).to eq 1
      open_email("example@example.com")

      expect(current_email).to have_subject("Please confirm your comment")

      comment = Comment.find_by_text("I think this is a really good ideas")
      expect(current_email.default_part_body.to_s)
        .to include(confirmed_comment_url(id: comment.confirm_id,
                                          protocol: "https",
                                          host: 'dev.planningalerts.org.au'))
    end
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
    VCR.use_cassette('planningalerts') do
      comment = create(:comment, confirmed: true, text: "I'm saying something abusive", name: "Jack Rude", email: "rude@foo.com", id: "23")
      visit(new_comment_report_path(comment))
    end

    fill_in("Your name", with: "Joe Reporter")
    fill_in("Your email", with: "reporter@foo.com")
    fill_in("Why should this comment be removed?", with: "You can't be rude to people!")
    click_button("Send report")

    page.should have_content("The comment has been reported and a moderator will look into it as soon as possible.")
    page.should have_content("Thanks for taking the time let us know about this.")

    unread_emails_for("moderator@planningalerts.org.au").size.should == 1
    open_email("moderator@planningalerts.org.au")
    current_email.should be_delivered_from("Joe Reporter <reporter@foo.com>")
    current_email.should have_subject("PlanningAlerts: Abuse report")
  end

  context "when signed in as admin" do
    background do
      admin = create(:admin)

      visit new_user_session_path
      within("#new_user") do
        fill_in "Email", with: admin.email
        fill_in "Password", with: admin.password
      end
      click_button "Sign in"
      expect(page).to have_content "Signed in successfully"
    end

    scenario "Getting an error message if the comment form isn’t completed correctly" do
      authority = create(:authority, full_name: "Foo", email: "feedback@foo.gov.au")
      VCR.use_cassette('planningalerts') do
        application = create(:application, id: "1", authority_id: authority.id)
        visit(application_path(application))
      end

      fill_in("Have your say on this application", with: "I think this is a really good idea")
      fill_in("Your name", with: "Matthew Landauer")
      fill_in("Your email", with: "example@example.com")
      # Don't fill in the address
      click_button("Post your public comment")

      page.should have_content("Some of the comment wasn't filled out completely. See below.")
      page.should_not have_content("Now check your email")
    end
  end

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end
