# frozen_string_literal: true

require "spec_helper"

describe "Signing up for an API account" do
  it "Successfully signing up", truncation: true do
    visit "/api/howto"
    click_link "Register for an account"

    fill_in "Email", with: "henare@oaf.org.au"
    fill_in "Your name", with: "Henare Degan"
    fill_in "Password", with: "password"
    click_button "Register"

    expect(page).to have_content "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
    expect(User.find_by(email: "henare@oaf.org.au").name).to eq "Henare Degan"

    expect(unread_emails_for("henare@oaf.org.au").size).to eq(1)
    open_email("henare@oaf.org.au")
    expect(current_email).to have_subject("Please confirm your account")
    expect(current_email.default_part_body.to_s).to include("Please click on the link below to confirm your email address to register for a PlanningAlerts")
  end
end
