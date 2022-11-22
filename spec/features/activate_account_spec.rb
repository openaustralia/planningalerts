# frozen_string_literal: true

require "spec_helper"

describe "Activate account" do
  it "Successfully does a normal password reset on account" do
    create(:confirmed_user, email: "matthew@oaf.org.au")
    encrypted_password = User.find_by(email: "matthew@oaf.org.au").encrypted_password

    visit "/users/password/new"
    fill_in "Email", with: "matthew@oaf.org.au"
    click_button "Send me reset password instructions"

    expect(page).to have_content "If your email address exists in our database, you will receive a password recovery link"

    expect(unread_emails_for("matthew@oaf.org.au").size).to eq 1
    open_email("matthew@oaf.org.au")

    expect(current_email).to have_subject("Reset password instructions")
    expect(current_email.default_part_body.to_s).to include("Someone has requested a link to change your password. You can do this through the link below.")

    visit_in_email("Change my password")

    fill_in "New password", with: "my new password"
    click_button "Change my password"

    expect(page).to have_content "Your password has been changed successfully. You are now signed in"

    # The password should have changed
    expect(User.find_by(email: "matthew@oaf.org.au").encrypted_password).not_to eq encrypted_password
  end
end
