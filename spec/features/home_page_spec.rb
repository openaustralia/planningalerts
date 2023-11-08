# frozen_string_literal: true

require "spec_helper"

describe "Home page" do
  # TODO: Include this in spec/spec_helper.rb instead
  # See https://github.com/heartcombo/devise#controller-tests
  include Devise::Test::IntegrationHelpers

  describe "accessibility tests", js: true do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true, name: "Jane Ng")
      visit root_path
    end

    it "passes" do
      expect(page).to be_axe_clean
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders a snapshot for a visual diff", js: true do
      page.percy_snapshot("Home")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end
end
