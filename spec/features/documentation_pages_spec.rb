# frozen_string_literal: true

require "spec_helper"

describe "Browsing basic documentation pages" do
  # TODO: Include this in spec/spec_helper.rb instead
  # See https://github.com/heartcombo/devise#controller-tests
  include Devise::Test::IntegrationHelpers

  it "has an about page" do
    visit about_path
    expect(page).to have_content "The aim of this to enable shared scrutiny of what is being built"
  end

  describe "in the new design" do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true)
      visit faq_path
    end

    it "has a help page" do
      expect(page).to have_content "Help"
    end

    describe "accessibility tests", js: true do
      it "main content passes" do
        # Limiting check to main content to ignore (for the time being) colour contrast issues with the header and footer
        expect(page).to be_axe_clean.within("main")
      end

      it "page passes most" do
        # Also doing check across whole page so we catch issues like h1 not being used
        expect(page).to be_axe_clean.skipping("color-contrast")
      end
    end
  end
end
