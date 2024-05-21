# frozen_string_literal: true

require "spec_helper"

describe "Signing up for an API account" do
  include Devise::Test::IntegrationHelpers

  it "Successfully signing up", truncation: true do
    visit "/api/howto"
    click_link "Register for an account"

    fill_in "Your full name", with: "Henare Degan"
    fill_in "Email", with: "henare@oaf.org.au"
    fill_in "Password", with: "password"
    click_button "Create my account"

    expect(page).to have_content "You will shortly receive an email from PlanningAlerts.org.au. Click on the link in the email"
    expect(User.find_by(email: "henare@oaf.org.au").name).to eq "Henare Degan"

    expect(unread_emails_for("henare@oaf.org.au").size).to eq(1)
    open_email("henare@oaf.org.au")
    expect(current_email).to have_subject("PlanningAlerts: Confirmation instructions")
    expect(current_email.default_part_body.to_s).to include("Please confirm your account email by clicking the link below")
    expect(current_email.from).to eq(["no-reply@planningalerts.org.au"])
    # TODO: This should be changed to "Planning Alerts"
    expect(current_email[:from].display_names).to eq(["PlanningAlerts"])
  end

  describe "Check your email page in the new design" do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true)
      visit root_path
      sign_out :user
      visit check_email_user_registration_path
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", js: true do
      page.percy_snapshot("Registration check email")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe "resending confirmation instructions in new design" do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true)
      visit root_path
      sign_out :user
      visit new_user_confirmation_path
    end

    it "shows the page" do
      expect(page).to have_content("Resend confirmation instructions")
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", js: true do
      page.percy_snapshot("Resend confirmation")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe "reset your password in the new design" do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true, email: "matthew@oaf.org.au")
      visit root_path
      sign_out :user
      # Need to be logged out to visit the reset password page
      visit new_user_password_path
    end

    it "tells you what to do" do
      expect(page).to have_content("Send me reset password instructions")
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", js: true do
      page.percy_snapshot("Reset password")
    end
    # rubocop:enable RSpec/NoExpectationExample

    describe "putting in an email address" do
      before do
        fill_in "Email", with: "matthew@oaf.org.au"
        click_button "Send me reset password instructions"
      end

      it "tells me to check my email" do
        expect(page).to have_content("you will receive a password recovery link at your email address")
      end

      it "has sent an email" do
        expect(unread_emails_for("matthew@oaf.org.au").size).to eq(1)
      end

      it "tells the user what to do" do
        open_email("matthew@oaf.org.au")
        # TODO: The subject line should be changed to "Planning Alerts" in /app/config/locales/devise.en.yml
        # Do this after we've completely moved over to the new theme
        expect(current_email).to have_subject("PlanningAlerts: Reset password instructions")
        expect(current_email.default_part_body.to_s).to include("Please click the button below and follow the instructions")
      end

      describe "clicking the link in the email" do
        before do
          open_email("matthew@oaf.org.au")
          click_email_link_matching(/reset_password_token/)
        end

        it "tells the user what to do" do
          expect(page).to have_content("Change your password")
        end

        # rubocop:disable RSpec/NoExpectationExample
        it "renders the page", js: true do
          page.percy_snapshot("Reset password step 2")
        end
        # rubocop:enable RSpec/NoExpectationExample
      end
    end
  end
end
