# frozen_string_literal: true

require "spec_helper"

describe "Give feedback" do
  include Devise::Test::IntegrationHelpers

  # In order to affect the outcome of a development application
  # As a citizen
  # I want to send feedback on a development application directly to the planning authority

  it "Giving feedback for an authority without a feedback email" do
    authority = create(:authority, full_name: "Foo")
    application = create(:geocoded_application, id: "1", authority:)
    visit(application_path(application))

    expect(page).to have_content("To comment on this application you will need to go to the original source")
  end

  it "Getting an error message if the comment form isn’t completed correctly" do
    authority = create(:authority, full_name: "Foo", email: "feedback@foo.gov.au")
    application = create(:geocoded_application, id: "1", authority:)

    sign_in create(:confirmed_user)
    visit(application_path(application))

    fill_in("Your comment", with: "I think this is a really good idea")
    fill_in("Your name", with: "Matthew Landauer")
    # Don't fill in the address
    click_button("Post your public comment")

    expect(page).to have_content("Some of the comment wasn't filled out completely. See below.")
    expect(page).not_to have_content("Now check your email")
  end

  context "when the authority is contactable" do
    let(:application) do
      authority = create(:contactable_authority,
                         full_name: "Foo",
                         email: "feedback@foo.gov.au")
      create(:geocoded_application, id: "1", authority:)
    end

    it "Adding a comment" do
      sign_in create(:confirmed_user)
      visit(application_path(application))

      fill_in("Your comment", with: "I think this is a really good ideas")
      fill_in("Your name", with: "Matthew Landauer")
      fill_in("Your street address", with: "11 Foo Street")
      click_button("Post your public comment")

      expect(page).to have_content("Your comment has been sent to Foo and posted below.")
    end

    context "when on the new design" do
      before do
        sign_in create(:confirmed_user, tailwind_theme: true)
        visit(application_path(application))
      end

      it "Adding a comment should take you to a preview page" do
        fill_in("Your comment", with: "I think this is a really good ideas")
        fill_in("Your full name", with: "Matthew Landauer")
        fill_in("Your address", with: "11 Foo Street")
        click_button("Review and publish")

        expect(page).to have_content("Does this look right?")
        expect(page).to have_content("I think this is a really good ideas")
      end

      it "Adding a comment should not be immediately publically visible in the comments section" do
        fill_in("Your comment", with: "I think this is a really good ideas")
        fill_in("Your full name", with: "Matthew Landauer")
        fill_in("Your address", with: "11 Foo Street")
        click_button("Review and publish")

        visit(application_path(application))
        within("#comments") do
          expect(page).not_to have_content("I think this is a really good ideas")
        end
      end

      it "Adding a comment should be pre-populated in the form when you return" do
        fill_in("Your comment", with: "I think this is a really good ideas")
        fill_in("Your full name", with: "Matthew Landauer")
        fill_in("Your address", with: "11 Foo Street")
        click_button("Review and publish")

        visit(application_path(application))
        within("#add-comment") do
          expect(page).to have_content("I think this is a really good ideas")
        end
      end

      it "Editing a comment that hasn't yet been published" do
        fill_in("Your comment", with: "I think this is a really good ideas")
        fill_in("Your full name", with: "Matthew Landauer")
        fill_in("Your address", with: "11 Foo Street")
        click_button("Review and publish")

        visit(application_path(application))
        fill_in("Your comment", with: "I'm not so sure this is a good idea")
        click_button("Review and publish")
        expect(page).to have_content("Does this look right?")
        expect(page).to have_content("I'm not so sure this is a good idea")
        expect(page).to have_content("Matthew Landauer")
      end

      it "Deleting a comment that hasn't yet been published" do
        fill_in("Your comment", with: "I think this is a really good ideas")
        fill_in("Your full name", with: "Matthew Landauer")
        fill_in("Your address", with: "11 Foo Street")
        click_button("Review and publish")

        visit(application_path(application))
        click_button("Clear form")

        expect(page).not_to have_content("I think this is a really good ideas")
      end

      it "Publishing a comment should make the comment visible to everyone" do
        fill_in("Your comment", with: "I think this is a really good ideas")
        fill_in("Your full name", with: "Matthew Landauer")
        fill_in("Your address", with: "11 Foo Street")
        click_button("Review and publish")
        click_button("Publish")
        within("#comments") do
          expect(page).to have_content("I think this is a really good ideas")
        end
      end
    end

    it "Unconfirmed comment should not be shown" do
      create(:comment, confirmed: false, text: "I think this is a really good ideas", application:)

      visit(application_path(application))

      expect(page).not_to have_content("I think this is a really good ideas")
    end

    context "when confirming the comment" do
      let(:comment) do
        create(:comment, confirmed: false, previewed: true, text: "I think this is a really good ideas", application:)
      end

      it "publishes the comment" do
        visit(confirmed_comment_path(id: comment.confirm_id))

        expect(page).to have_content("Your comment has been sent to Foo and posted below.")
        expect(page).to have_content("I think this is a really good ideas")

        expect(unread_emails_for("feedback@foo.gov.au").size).to eq(1)
        open_email("feedback@foo.gov.au")
        expect(current_email.default_part_body.to_s).to include("I think this is a really good ideas")
      end

      it "twice should not send the comment twice" do
        visit(confirmed_comment_path(id: comment.confirm_id))
        visit(confirmed_comment_path(id: comment.confirm_id))

        expect(unread_emails_for("feedback@foo.gov.au").size).to eq(1)
      end
    end

    it "Viewing the comment on the application page" do
      comment = create(:comment, confirmed: false, previewed: true, text: "I think this is a really good ideas", application:)

      visit(confirmed_comment_path(id: comment.confirm_id))

      expect(page).to have_content("commented less than a minute ago")
      expect(page).to have_content("I think this is a really good ideas")
    end

    it "Sharing new comment on facebook" do
      comment = create(:unconfirmed_comment, application:)

      visit(confirmed_comment_path(id: comment.confirm_id))

      expect(page).to have_content("Share your comment on Facebook")
    end
  end

  it "Reporting abuse on a confirmed comment" do
    comment = create(:confirmed_comment, text: "I'm saying something abusive", name: "Jack Rude", user: create(:user, email: "rude@foo.com"), id: "23")

    sign_in create(:confirmed_user, email: "reporter@foo.com", name: "Joe Reporter")
    visit(new_comment_report_path(comment))

    fill_in("Why should this comment be removed?", with: "You can't be rude to people!")
    click_button("Send report")

    expect(page).to have_content("The comment has been reported and a moderator will look into it as soon as possible.")
    expect(page).to have_content("Thanks for taking the time let us know about this.")

    expect(unread_emails_for("contact@planningalerts.org.au").size).to eq(1)
    open_email("contact@planningalerts.org.au")
    expect(current_email).to be_delivered_from("Joe Reporter <contact@planningalerts.org.au>")
    expect(current_email).to have_reply_to("Joe Reporter <reporter@foo.com>")
    expect(current_email).to have_subject("PlanningAlerts: Abuse report")
  end

  it "reporting abuse when user doesn't have a name set" do
    comment = create(:confirmed_comment, text: "I'm saying something abusive", name: "Jack Rude", user: create(:user, email: "rude@foo.com"), id: "23")

    sign_in create(:confirmed_user, email: "reporter@foo.com")
    visit(new_comment_report_path(comment))

    fill_in("Why should this comment be removed?", with: "You can't be rude to people!")
    click_button("Send report")

    expect(page).to have_content("The comment has been reported and a moderator will look into it as soon as possible.")
    expect(page).to have_content("Thanks for taking the time let us know about this.")

    expect(unread_emails_for("contact@planningalerts.org.au").size).to eq(1)
    open_email("contact@planningalerts.org.au")
    expect(current_email).to be_delivered_from("contact@planningalerts.org.au")
    expect(current_email).to have_reply_to("reporter@foo.com")
    expect(current_email).to have_subject("PlanningAlerts: Abuse report")
  end
end
