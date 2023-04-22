# frozen_string_literal: true

require "spec_helper"

describe "Contact us" do
  include Devise::Test::IntegrationHelpers

  context "when not signed in" do
    it "fills out the contact us form and the admins receive an email" do
      visit "/help/contact"
      fill_in "Your name", with: "Matthew Landauer"
      fill_in "Your email", with: "matthew@oaf.org.au"
      select "The address or map location is wrong", from: "I'm getting in touch because"
      fill_in "Please tell us briefly about your request", with: "Actually nothing is wrong here. Sorry."
      attach_file "Attach files or screenshots", "spec/fixtures/attachment.txt"
      click_button "Send message to the Planning Alerts team"

      expect(page).to have_content("Thank you for getting in touch")
      expect(unread_emails_for("contact@planningalerts.org.au").size).to eq(1)
      open_email("contact@planningalerts.org.au")
      expect(current_email).to have_subject("Contact form: The address or map location is wrong")
      expect(current_email.default_part_body.to_s).to include("Actually nothing is wrong here. Sorry")
      expect(current_email).to have_reply_to("matthew@oaf.org.au")

      # Check that the attachment is in the sent email as well (as a link)
      urls = Nokogiri::HTML(current_email.default_part_body).css("a").pluck("href")
      expect(urls.count).to eq 1
      visit urls.first
      expect(page).to have_content("This is an attachment you might attach to a contact message")
    end
  end

  context "when signed in" do
    let(:user) { create(:confirmed_user, name: "Matthew Landauer", email: "matthew@oaf.org.au") }

    before { sign_in user }

    it "less information needs to be filled out and the admins receive an email" do
      visit "/help/contact"
      select "The address or map location is wrong", from: "I'm getting in touch because"
      fill_in "Please tell us briefly about your request", with: "Actually nothing is wrong here. Sorry."
      click_button "Send message to the Planning Alerts team"

      expect(page).to have_content("Thank you for getting in touch")
      expect(unread_emails_for("contact@planningalerts.org.au").size).to eq(1)
      open_email("contact@planningalerts.org.au")
      expect(current_email).to have_subject("Contact form: The address or map location is wrong")
      expect(current_email.default_part_body.to_s).to include("Actually nothing is wrong here. Sorry")
      expect(current_email).to have_reply_to("matthew@oaf.org.au")
    end
  end
end
