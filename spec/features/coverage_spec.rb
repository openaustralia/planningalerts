# frozen_string_literal: true

require "spec_helper"

describe "Coverage" do
  include Devise::Test::IntegrationHelpers

  describe "in the new design" do
    before do
      # Give a name to the user so screenshots are consistent with percy
      sign_in create(:confirmed_user, name: "Jane Ng")
      visit authorities_path
    end

    describe "accessibility test", :js do
      it "passes" do
        expect(page).to be_axe_clean
      end
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", :js do
      page.percy_snapshot("Coverage")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end
end
