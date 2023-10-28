# frozen_string_literal: true

require "spec_helper"

describe "Home page" do
  include Devise::Test::IntegrationHelpers

  it "is accessible", js: true do
    pending "there are accessibility issues to fix on the home page in the new design"
    sign_in create(:confirmed_user, tailwind_theme: true)
    visit root_path
    # page.save_screenshot("screenshot.png")
    # save_and_open_screenshot
    expect(page).to be_axe_clean
  end
end
