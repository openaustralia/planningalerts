# frozen_string_literal: true

require "spec_helper"

describe "Activate account" do
  include Devise::Test::IntegrationHelpers

  context "when in the new design" do
    before do
      visit new_users_activation_path
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", :js do
      page.percy_snapshot("Activate account")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  context "when on the check your email page in the new design" do
    before do
      visit check_email_users_activation_path
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", :js do
      page.percy_snapshot("Activate check email")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  context "when on final activate your account page in the new design" do
    before do
      # Strictly this page needs a token to function but for the purposes of this we don't need to do that
      visit edit_users_activation_path
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", :js do
      page.percy_snapshot("Activate step 2")
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
      fill_in "Email", with: "matthew@oaf.org.au"
      click_on "Send me an email"

      expect(page).to have_content "Now check your email"

      expect(unread_emails_for("matthew@oaf.org.au").size).to eq 1
      open_email("matthew@oaf.org.au")

      expect(current_email).to have_subject("PlanningAlerts: Activate your account")
      expect(current_email.default_part_body.to_s).to include("Thanks for getting onboard!")

      # Do these shenanigans to get the first link in this case
      link = links_in_email(current_email).find { |u| u =~ %r{https://dev\.planningalerts\.org\.au} }
      visit request_uri(link)

      fill_in "Your full name", with: "Matthew"
      fill_in "Password", with: "my new password"
      click_on "Activate my account"

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
      fill_in "Email", with: "matthew@oaf.org.au"
      click_on "Send me an email"

      expect(page).to have_content "Account with that email address has already been activated"
    end
  end

  context "with a non-existent user" do
    it "shows an error message" do
      visit "/users/activation/new"
      fill_in "Email", with: "matthew@oaf.org.au"
      click_on "Send me an email"

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
      fill_in "Email", with: "matthew@oaf.org.au"
      click_on "Send me an email"

      expect(page).to have_content "Now check your email"

      expect(unread_emails_for("matthew@oaf.org.au").size).to eq 1
      open_email("matthew@oaf.org.au")

      expect(current_email).to have_subject("PlanningAlerts: Activate your account")
      expect(current_email.default_part_body.to_s).to include("Thanks for getting onboard!")

      # Do these shenanigans to get the first link in this case
      link = links_in_email(current_email).find { |u| u =~ %r{https://dev\.planningalerts\.org\.au} }
      visit request_uri(link)

      fill_in "Your full name", with: "Matthew"
      fill_in "Password", with: "my new password"
      click_on "Activate my account"

      expect(page).to have_content "Your account is now activated. You are now signed in"
      expect(page).to have_content "Matthew"

      user = User.find_by(email: "matthew@oaf.org.au")
      expect(user.name).to eq "Matthew"
      expect(user.encrypted_password).not_to be_nil
    end
  end
end
