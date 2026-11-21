# frozen_string_literal: true

require "spec_helper"

describe "Home page" do
  # TODO: #2166 Include this in spec/spec_helper.rb instead
  # See https://github.com/heartcombo/devise#controller-tests
  include Devise::Test::IntegrationHelpers

  it "shows what the service is" do
    visit root_path
    expect(page).to have_content "What is being built and knocked down in your area?"
    expect(page).to have_site_layout
    expect(page).to have_no_broken_internal_links
    expect(page).to have_no_missing_assets
  end

  describe "accessibility tests", :js do
    before do
      sign_in create(:confirmed_user, name: "Jane Ng")
      visit root_path
    end

    it "passes" do
      expect(page).to be_axe_clean
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders a snapshot for a visual diff", :js do
      page.percy_snapshot("Home")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end
end
