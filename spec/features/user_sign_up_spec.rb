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
end
