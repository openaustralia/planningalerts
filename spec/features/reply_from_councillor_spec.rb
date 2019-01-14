# frozen_string_literal: true

require "spec_helper"

feature "Councillor replies to a message sent to them" do
  given(:councillor) { create(:councillor, name: "Louise Councillor", email: "louise@council.nsw.gov.au", popolo_id: "marrickville_council/chris_woods") }
  given(:application) { create(:geocoded_application, id: 8, address: "24 Bruce Road Glenbrook", description: "A lovely house") }
  given!(:comment) do
    create(:comment, id: 5,
                     application: application,
                     name: "Matthew Landauer",
                     councillor: councillor,
                     text: "I think this is a really good idea")
  end

  scenario "it's entered by an admin and displayed on the application page" do
    comment.confirm!
    open_email("louise@council.nsw.gov.au")
    expect(current_email).to have_reply_to "replies@planningalerts.org.au"
    # The councillor replies to the message
    # It's sent to replies@planningalerts.org.au
    # An admin checks this mailbox

    ## The admin enters the reply into the admin backend
    sign_in_as_admin
    # Find the original comment from the reply and visit it
    visit application_path application
    within("#comment5") { click_link "add reply" }
    # Enter the reply
    select "Louise Councillor", from: "Councillor"
    fill_in "Text", with: "I'm glad you think it's a good idea. I do too."
    select "2015", from: "Year"
    select "November", from: "Month"
    select "9", from: "Day"
    select "15", from: "Hour"
    select "01", from: "Minute"
    click_button "Create Reply"

    visit application_path application
    expect(page).to have_content "I'm glad you think it's a good idea. I do too."
  end

  context "WriteIt is configured" do
    given(:writeit_comment) do
      create(:confirmed_comment, writeit_message_id: 1234,
                                 application: application,
                                 councillor: councillor)
    end

    around do |test|
      with_modified_env(writeit_config_variables) do
        test.run
      end
    end

    scenario "it’s loaded from WriteIt by an admin" do
      sign_in_as_admin
      visit admin_comment_path(writeit_comment)
      VCR.use_cassette("writeit") do
        click_button "Load replies from WriteIt"
      end

      expect(page).to have_content "Loaded 1 replies"

      visit application_path(writeit_comment.application)

      expect(page).to have_content "I agree, thanks for your comment"
    end
  end
end

feature "Commenter is notified of the councillors reply" do
  given(:authority)   { create(:authority, full_name: "Marrickville Council") }
  given(:councillor)  { create(:councillor, name: "Louise Councillor", authority: authority) }
  given(:application) do
    create(:geocoded_application, id: 8, address: "24 Bruce Road Glenbrook", description: "A lovely house")
  end

  # TODO: Extract this to a method where user actually leaves comment
  #       and confirms it.
  given(:comment) do
    create(:comment,
           :confirmed,
           id: 5,
           email: "matthew@openaustralia.org",
           application: application,
           councillor: councillor)
  end
  given(:email_intro_text) { "Local councillor Louise Councillor replied to <a href=\"https://dev.planningalerts.org.au/applications/8?utm_campaign=view-comment&utm_medium=email&utm_source=reply-notifications#comment5\">your message</a> about the planning application “A lovely house” at 24 Bruce Road Glenbrook" }
  given(:reply_text) { "I'm glad you think it's a good idea. I do too." }

  background do
    create(:reply, comment: comment, councillor: councillor, text: reply_text)
  end

  scenario "commenter gets an email with the councillor’s reply" do
    open_email_for("matthew@openaustralia.org", with_subject: "Local Councillor Louise Councillor replied to your message")
    expect(current_email).to have_subject "Local Councillor Louise Councillor replied to your message"
    expect(current_email).to have_body_text email_intro_text
    expect(current_email).to have_body_text reply_text

    click_first_link_in_email
    expect(page).to have_content "Louise Councillor local councillor for Marrickville Council\nreplied to Matthew Landauer"
  end
end
