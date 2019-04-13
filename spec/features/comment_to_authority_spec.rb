# frozen_string_literal: true

require "spec_helper"

feature "Give feedback" do
  # In order to affect the outcome of a development application
  # As a citizen
  # I want to send feedback on a development application directly to the planning authority

  scenario "Giving feedback for an authority without a feedback email" do
    authority = create(:authority, full_name: "Foo")
    application = create_geocoded_application(id: "1", authority: authority, comment_url: "mailto:foo@bar.com")
    visit(application_path(application))

    expect(page).to have_content("How to comment on this application")
  end

  scenario "Hide feedback form where there is no feedback email or comment_url" do
    authority = create(:authority, full_name: "Foo")
    application = create_geocoded_application(id: "1", authority: authority)
    visit(application_path(application))

    expect(page).not_to have_content("How to comment on this application")
  end

  scenario "Getting an error message if the comment form isn’t completed correctly" do
    authority = create(:authority, full_name: "Foo", email: "feedback@foo.gov.au")
    application = create_geocoded_application(id: "1", authority: authority)
    visit(application_path(application))

    fill_in("Have your say on this application", with: "I think this is a really good idea")
    fill_in("Your name", with: "Matthew Landauer")
    fill_in("Your email", with: "example@example.com")
    # Don't fill in the address
    click_button("Post your public comment")

    expect(page).to have_content("Some of the comment wasn't filled out completely. See below.")
    expect(page).not_to have_content("Now check your email")
  end

  context "when the authority is contactable" do
    given(:application) do
      authority = create(:contactable_authority,
                         full_name: "Foo",
                         email: "feedback@foo.gov.au")
      create_geocoded_application(id: "1", authority: authority)
    end

    scenario "Adding a comment" do
      visit(application_path(application))

      fill_in("Have your say on this application", with: "I think this is a really good ideas")
      fill_in("Your name", with: "Matthew Landauer")
      fill_in("Your email", with: "example@example.com")
      fill_in("Your street address", with: "11 Foo Street")
      click_button("Post your public comment")

      expect(page).to have_content("Now check your email")
      expect(page).to have_content("Click on the link in the email to confirm your comment")

      expect(unread_emails_for("example@example.com").size).to eq(1)
      open_email("example@example.com")
      expect(current_email).to have_subject("Please confirm your comment")
      # And the email body should contain a link to the confirmation page
      comment = Comment.find_by(text: "I think this is a really good ideas")
      expect(current_email.default_part_body.to_s).to include(confirmed_comment_url(id: comment.confirm_id, protocol: "https", host: "dev.planningalerts.org.au"))
    end

    context "when the write to councillor feature is on but not for this authority" do
      around do |test|
        with_modified_env COUNCILLORS_ENABLED: "true" do
          test.run
        end
      end

      background do
        application.authority.update!(write_to_councillors_enabled: false)

        create(:councillor, authority: application.authority)
      end

      scenario "Adding a comment for the planning authority" do
        visit(application_path(application))

        fill_in("Have your say on this application", with: "I think this is a really good ideas")
        fill_in("Your name", with: "Matthew Landauer")
        fill_in("Your email", with: "example@example.com")
        fill_in("Your street address", with: "11 Foo Street")
        click_button("Post your public comment")

        expect(page).to have_content("Now check your email")
        expect(page).to have_content("Click on the link in the email to confirm your comment")

        expect(unread_emails_for("example@example.com").size).to eq(1)
        open_email("example@example.com")
        expect(current_email).to have_subject("Please confirm your comment")
        # And the email body should contain a link to the confirmation page
        comment = Comment.find_by(text: "I think this is a really good ideas")
        expect(current_email.default_part_body.to_s).to include(confirmed_comment_url(id: comment.confirm_id, protocol: "https", host: "dev.planningalerts.org.au"))
      end
    end

    context "when there is the option to write to a councillor" do
      around do |test|
        with_modified_env COUNCILLORS_ENABLED: "true" do
          test.run
        end
      end

      background do
        application.authority.update!(write_to_councillors_enabled: true)

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

        comment = Comment.find_by(text: "I think this is a really good ideas")
        expect(current_email.default_part_body.to_s)
          .to include(confirmed_comment_url(id: comment.confirm_id,
                                            protocol: "https",
                                            host: "dev.planningalerts.org.au"))
      end
    end

    scenario "Unconfirmed comment should not be shown" do
      create(:comment, confirmed: false, text: "I think this is a really good ideas", application: application)

      visit(application_path(application))

      expect(page).not_to have_content("I think this is a really good ideas")
    end

    context "confirming the comment" do
      given(:comment) do
        create(:comment, confirmed: false, text: "I think this is a really good ideas", application: application)
      end

      scenario "should publish the comment" do
        visit(confirmed_comment_path(id: comment.confirm_id))

        expect(page).to have_content("Your comment has been sent to Foo and posted below.")
        expect(page).to have_content("I think this is a really good ideas")

        expect(unread_emails_for("feedback@foo.gov.au").size).to eq(1)
        open_email("feedback@foo.gov.au")
        expect(current_email.default_part_body.to_s).to include("I think this is a really good ideas")
      end

      scenario "twice should not send the comment twice" do
        visit(confirmed_comment_path(id: comment.confirm_id))
        visit(confirmed_comment_path(id: comment.confirm_id))

        expect(unread_emails_for("feedback@foo.gov.au").size).to eq(1)
      end
    end

    scenario "Viewing the comment on the application page" do
      comment = create(:comment, confirmed: false, text: "I think this is a really good ideas", application: application)

      visit(confirmed_comment_path(id: comment.confirm_id))

      expect(page).to have_content("commented less than a minute ago")
      expect(page).to have_content("I think this is a really good ideas")
    end

    scenario "Sharing new comment on facebook" do
      comment = create(:unconfirmed_comment, application: application)

      visit(confirmed_comment_path(id: comment.confirm_id))

      expect(page).to have_content("Share your comment on Facebook")
    end
  end

  scenario "Reporting abuse on a confirmed comment" do
    comment = create(:confirmed_comment, text: "I'm saying something abusive", name: "Jack Rude", email: "rude@foo.com", id: "23")
    visit(new_comment_report_path(comment))

    fill_in("Your name", with: "Joe Reporter")
    fill_in("Your email", with: "reporter@foo.com")
    fill_in("Why should this comment be removed?", with: "You can't be rude to people!")
    click_button("Send report")

    expect(page).to have_content("The comment has been reported and a moderator will look into it as soon as possible.")
    expect(page).to have_content("Thanks for taking the time let us know about this.")

    expect(unread_emails_for("moderator@planningalerts.org.au").size).to eq(1)
    open_email("moderator@planningalerts.org.au")
    expect(current_email).to be_delivered_from("Joe Reporter <moderator@planningalerts.org.au>")
    expect(current_email).to have_reply_to("Joe Reporter <reporter@foo.com>")
    expect(current_email).to have_subject("PlanningAlerts: Abuse report")
  end

  context "when signed in as admin" do
    background do
      sign_in_as_admin
    end

    scenario "Getting an error message if the comment form isn’t completed correctly" do
      authority = create(:authority, full_name: "Foo", email: "feedback@foo.gov.au")
      application = create_geocoded_application(id: "1", authority: authority)
      visit(application_path(application))

      fill_in("Have your say on this application", with: "I think this is a really good idea")
      fill_in("Your name", with: "Matthew Landauer")
      fill_in("Your email", with: "example@example.com")
      # Don't fill in the address
      click_button("Post your public comment")

      expect(page).to have_content("Some of the comment wasn't filled out completely. See below.")
      expect(page).not_to have_content("Now check your email")
    end
  end
end
