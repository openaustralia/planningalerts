# frozen_string_literal: true

require "spec_helper"

describe "ALTCHA on the sign up form" do
  include Devise::Test::IntegrationHelpers

  before do
    Flipper.enable(:altcha)
    Flipper.enable(:altcha_enforce)
    # The browser does this arithmetic for real. Keep it small or the examples
    # take as long as they would on somebody's phone.
    stub_const("CreateAltchaChallengeService::COST", 500)
    visit new_user_registration_path
  end

  # The widget starts on load and fills the hidden field when it is done.
  # Waiting for that is what makes these examples deterministic, and it is why
  # they don't use the widget's own test attribute: that makes it report success
  # while submitting a payload with no challenge in it, which the server can
  # never verify, so it could never prove the round trip.
  def wait_for_altcha
    expect(page).to have_field("altcha", type: :hidden, with: /.+/, wait: 30)
  end

  it "lets somebody sign up once the browser has solved the challenge", :truncation do
    wait_for_altcha

    fill_in "Your full name", with: "Jane Citizen"
    fill_in "Email", with: "jane@example.com"
    fill_in "Create a password", with: "correct horse battery"
    click_on "Create my account"

    expect(page).to have_content "You will shortly receive an email from PlanningAlerts.org.au"
    expect(User.find_by(email: "jane@example.com")).to be_present
  end

  it "passes an accessibility check", :js do
    wait_for_altcha

    expect(page).to be_axe_clean
  end

  # rubocop:disable RSpec/NoExpectationExample
  it "renders the page", :js do
    wait_for_altcha
    page.percy_snapshot("Sign up with ALTCHA")
  end
  # rubocop:enable RSpec/NoExpectationExample
end
