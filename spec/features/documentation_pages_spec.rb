# frozen_string_literal: true

require "spec_helper"

describe "Browsing basic documentation pages" do
  # TODO: Include this in spec/spec_helper.rb instead
  # See https://github.com/heartcombo/devise#controller-tests
  include Devise::Test::IntegrationHelpers

  describe "about page" do
    it "has an about page" do
      visit about_path
      expect(page).to have_content "The aim of this to enable shared scrutiny of what is being built"
    end

    describe "in the new design" do
      before do
        # Give a name to the user so screenshots are consistent with percy
        sign_in create(:confirmed_user, tailwind_theme: true, name: "Jane Ng")
        visit about_path
      end

      describe "accessibility test", js: true do
        it "passes" do
          expect(page).to be_axe_clean
        end
      end

      # rubocop:disable RSpec/NoExpectationExample
      it "renders the page", js: true do
        page.percy_snapshot("About")
      end
      # rubocop:enable RSpec/NoExpectationExample
    end
  end

  describe "help page in the new design" do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true)
      visit faq_path
    end

    it "has a help page" do
      expect(page).to have_content "Help"
    end

    describe "accessibility tests", js: true do
      it "passes" do
        expect(page).to be_axe_clean
      end
    end
  end

  describe "contact us page in the new design" do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true)
      visit documentation_contact_path
    end

    describe "accessibility tests", js: true do
      it "passes" do
        expect(page).to be_axe_clean
      end
    end
  end

  describe "api page in the new design" do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true)
      visit api_howto_path
    end

    describe "accessibility tests", js: true do
      it "passes" do
        expect(page).to be_axe_clean
      end
    end
  end

  describe "get involved page in the new design" do
    before do
      sign_in create(:confirmed_user, tailwind_theme: true, name: "Jane Ng")
      visit get_involved_path
    end

    describe "accessibility tests", js: true do
      it "passes" do
        expect(page).to be_axe_clean
      end
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders a snapshot for a visual diff", js: true do
      page.percy_snapshot("Get Involved")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end
end
