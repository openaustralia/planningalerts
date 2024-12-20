# frozen_string_literal: true

require "spec_helper"

describe "Signing up for an API account" do
  include Devise::Test::IntegrationHelpers

  it "Successfully signing up", :truncation do
    visit "/api/developer"
    click_on "register for an account"

    fill_in "Your full name", with: "Henare Degan"
    fill_in "Email", with: "henare@oaf.org.au"
    fill_in "Create a password", with: "password"
    click_on "Create my account"

    expect(page).to have_content "You will shortly receive an email from PlanningAlerts.org.au"
    expect(User.find_by(email: "henare@oaf.org.au").name).to eq "Henare Degan"

    expect(unread_emails_for("henare@oaf.org.au").size).to eq(1)
    open_email("henare@oaf.org.au")
    expect(current_email).to have_subject("PlanningAlerts: Confirmation instructions")
    expect(current_email.default_part_body.to_s).to include("Thanks for getting onboard!")
    expect(current_email.from).to eq(["no-reply@planningalerts.org.au"])
    # TODO: This should be changed to "Planning Alerts"
    expect(current_email[:from].display_names).to eq(["PlanningAlerts"])
  end

  describe "Check your email page in the new design" do
    before do
      visit check_email_user_registration_path
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", :js do
      page.percy_snapshot("Registration check email")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe "resending confirmation instructions in new design" do
    before do
      visit new_user_confirmation_path
    end

    it "shows the page" do
      expect(page).to have_content("Resend confirmation instructions")
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", :js do
      page.percy_snapshot("Resend confirmation")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe "reset your password in the new design" do
    before do
      create(:confirmed_user, email: "matthew@oaf.org.au")
      # Need to be logged out to visit the reset password page
      visit new_user_password_path
    end

    it "tells you what to do" do
      expect(page).to have_content("Let's get you to create a new password")
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", :js do
      page.percy_snapshot("Reset password")
    end
    # rubocop:enable RSpec/NoExpectationExample

    describe "putting in an email address" do
      before do
        fill_in "Email", with: "matthew@oaf.org.au"
        click_on "Send me an email"
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
        expect(current_email.default_part_body.to_s).to include("Thanks for confirming you are you")
      end

      describe "clicking the link in the email" do
        before do
          open_email("matthew@oaf.org.au")
          click_email_link_matching(/reset_password_token/)
        end

        it "tells the user what to do" do
          expect(page).to have_content("Create password")
        end

        # rubocop:disable RSpec/NoExpectationExample
        it "renders the page", :js do
          page.percy_snapshot("Reset password step 2")
        end
        # rubocop:enable RSpec/NoExpectationExample
      end
    end
  end
end
