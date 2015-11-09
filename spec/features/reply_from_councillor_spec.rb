require "spec_helper"

feature "Councillor replies to a message sent to them" do
  given (:councillor) { create(:councillor, name: "Louise Councillor", email: "louise@council.nsw.gov.au") }
  given (:application) { create(:application, id: 8, address: "24 Bruce Road Glenbrook", description: "A lovely house") }
  given (:comment) do
    VCR.use_cassette('planningalerts') do
      create(:comment, id: 5,
                       application: application,
                       name: "Matthew Landauer",
                       councillor: councillor,
                       text: "I think this is a really good idea")
    end
  end
  given (:admin) { create(:admin) }

  background { comment.confirm! }

  scenario "it's entered by an admin and displayed on the application page" do
    open_email("louise@council.nsw.gov.au")
    expect(current_email).to have_reply_to "replies@planningalerts.org.au"
    # The councillor replies to the message
    # It's sent to replies@planningalerts.org.au
    # An admin checks this mailbox

    ## The admin enters the reply into the admin backend
    # Sign in as an admin
    visit new_user_session_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: admin.password
    click_button "Sign in"
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
end

feature "Commenter is notified of the councillors reply" do
  given (:councillor) { create(:councillor, name: "Louise Councillor") }
  given (:application) { create(:application,
                                address: "24 Bruce Road Glenbrook") }
  given (:comment) do
    VCR.use_cassette('planningalerts') do
      create(:comment,
             :confirmed,
             email: "matthew@openaustralia.org",
             application: application)
    end
  end

  background do
    create(:reply, comment: comment)
  end

  scenario "commenter gets an email with the councillor’s reply" do
    open_last_email_for("matthew@openaustralia.org")
    expect(current_email).to have_subject "Local councillor Louise Councillor replied to your message"
  end
end
