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

  # This is where someone has a user account set up automatically because they have earlier
  # signed up for an email alert but that account doesn't yet have a password or name attached
  # This tests the whole reset password / account activation flow

  it "Successfully activates their account" do
    user = User.new(email: "matthew@oaf.org.au", from_alert_or_comment: true)
    # We don't want creating the user to send out a notification
    user.skip_confirmation_notification!
    # Because we want an empty password and name we have to disable validations
    user.save!(validate: false)
    # We also want this user to already be confirmed
    user.confirm

    visit "/users/password/new"
    fill_in "Email", with: "matthew@oaf.org.au"
    click_button "Send me reset password instructions"

    expect(page).to have_content "If your email address exists in our database, you will receive a password recovery link"

    expect(unread_emails_for("matthew@oaf.org.au").size).to eq 1
    open_email("matthew@oaf.org.au")

    expect(current_email).to have_subject("Reset password instructions")
    expect(current_email.default_part_body.to_s).to include("You don't currently have an active password")
    expect(current_email.default_part_body.to_s).to include("You can activate your account by following the link below")

    visit_in_email("Activate my account")

    # TODO: Do the rest of the actions of setting your password and name
  end
end
