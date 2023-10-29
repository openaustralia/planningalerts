# frozen_string_literal: true

require "spec_helper"

describe "Home page" do
  include Devise::Test::IntegrationHelpers

  describe "accessibility tests", js: true do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true)
      visit root_path
    end

    it "passes most" do
      expect(page).to be_axe_clean.skipping("color-contrast")
    end

    it "passes color-contrast" do
      pending "there are still outstanding issues"
      expect(page).to be_axe_clean.checking_only("color-contrast")
    end
  end
end
