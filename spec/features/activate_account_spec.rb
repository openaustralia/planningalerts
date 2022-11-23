# frozen_string_literal: true

require "spec_helper"

describe "Activate account" do
  context "with a confirmed user that has not been activated" do
    before do
      u = User.new(email: "matthew@oaf.org.au", from_alert_or_comment: true, confirmed_at: Time.zone.now)
      u.skip_confirmation_notification!
      u.save!(validate: false)
    end

    it "Successfully does an account activation" do
      visit "/users/activation/new"
      fill_in "Email", with: "matthew@oaf.org.au"
      click_button "Send me account activation instructions"

      expect(page).to have_content "If your email address exists in our database, you will receive an account activation link"

      expect(unread_emails_for("matthew@oaf.org.au").size).to eq 1
      open_email("matthew@oaf.org.au")

      expect(current_email).to have_subject("Account activation instructions")
      expect(current_email.default_part_body.to_s).to include("Someone has requested a link to activate your account. You can do this through the link below.")

      # visit_in_email("Activate my account")

      # fill_in "New password", with: "my new password"
      # click_button "Change my password"

      # expect(page).to have_content "Your password has been changed successfully. You are now signed in"

      # # The password should have changed
      # expect(User.find_by(email: "matthew@oaf.org.au").encrypted_password).not_to eq encrypted_password
    end
  end

  context "with an already activated user" do
    before do
      create(:confirmed_user, email: "matthew@oaf.org.au")
    end

    pending "should get a different email"
  end
end
