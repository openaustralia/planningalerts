# frozen_string_literal: true

require "spec_helper"

describe "Activate account" do
  include Devise::Test::IntegrationHelpers

  context "with a confirmed user that has not been activated in the new design" do
    before do
      # Do this weird dance to get us on to the new theme
      sign_in create(:confirmed_user, tailwind_theme: true)
      visit root_path
      sign_out :user

      u = User.new(email: "matthew@oaf.org.au", from_alert_or_comment: true, confirmed_at: Time.zone.now)
      u.skip_confirmation_notification!
      u.save!(validate: false)
      visit new_users_activation_path
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", js: true do
      page.percy_snapshot("Activate account")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  context "with a confirmed user that has not been activated" do
    before do
      u = User.new(email: "matthew@oaf.org.au", from_alert_or_comment: true, confirmed_at: Time.zone.now)
      u.skip_confirmation_notification!
      u.save!(validate: false)
    end

    it "Successfully does an account activation" do
      visit "/users/activation/new"
      fill_in "Your email", with: "matthew@oaf.org.au"
      click_button "Send account activation instructions to my email"

      expect(page).to have_content "Now check your email"

      expect(unread_emails_for("matthew@oaf.org.au").size).to eq 1
      open_email("matthew@oaf.org.au")

      expect(current_email).to have_subject("PlanningAlerts: Activate your account")
      expect(current_email.default_part_body.to_s).to include("Please click the link below and follow the instructions.")

      visit_in_email("Activate my account")

      fill_in "Your full name", with: "Matthew"
      fill_in "Password", with: "my new password"
      click_button "Activate my account"

      expect(page).to have_content "Your account is now activated. You are now signed in"
      expect(page).to have_content "Matthew"

      user = User.find_by(email: "matthew@oaf.org.au")
      expect(user.name).to eq "Matthew"
      expect(user.encrypted_password).not_to be_nil
    end
  end

  context "with an already activated user" do
    before do
      create(:confirmed_user, email: "matthew@oaf.org.au")
    end

    it "shows an error message" do
      visit "/users/activation/new"
      fill_in "Your email", with: "matthew@oaf.org.au"
      click_button "Send account activation instructions to my email"

      expect(page).to have_content "Account with that email address has already been activated"
    end
  end

  context "with a non-existent user" do
    it "shows an error message" do
      visit "/users/activation/new"
      fill_in "Your email", with: "matthew@oaf.org.au"
      click_button "Send account activation instructions to my email"

      expect(page).to have_content "We don't know recognise that email address"
    end
  end

  context "with an unconfirmed user that has not been activated" do
    before do
      u = User.new(email: "matthew@oaf.org.au", from_alert_or_comment: true)
      u.skip_confirmation_notification!
      u.save!(validate: false)
    end

    # Going through this we're effectively doing an activation and a confirmation at the same time
    it "Successfully does an account activation" do
      visit "/users/activation/new"
      fill_in "Your email", with: "matthew@oaf.org.au"
      click_button "Send account activation instructions to my email"

      expect(page).to have_content "Now check your email"

      expect(unread_emails_for("matthew@oaf.org.au").size).to eq 1
      open_email("matthew@oaf.org.au")

      expect(current_email).to have_subject("PlanningAlerts: Activate your account")
      expect(current_email.default_part_body.to_s).to include("Please click the link below and follow the instructions.")

      visit_in_email("Activate my account")

      fill_in "Your full name", with: "Matthew"
      fill_in "Password", with: "my new password"
      click_button "Activate my account"

      expect(page).to have_content "Your account is now activated. You are now signed in"
      expect(page).to have_content "Matthew"

      user = User.find_by(email: "matthew@oaf.org.au")
      expect(user.name).to eq "Matthew"
      expect(user.encrypted_password).not_to be_nil
    end
  end
end
