# frozen_string_literal: true

require "spec_helper"

describe "Comments pages" do
  include Devise::Test::IntegrationHelpers

  describe "in the new design" do
    let(:signed_in_user) { create(:confirmed_user, tailwind_theme: true, name: "Jane Ng") }

    before do
      sign_in(signed_in_user)
    end

    describe "index page" do
      before do
        create(:published_comment,
               text: "I am a resident the suburb. I object to the development application. My main concerns are the potential impacts on local wildlife.",
               name: "Andrew Citizen")
        create(:published_comment,
               text: "I disagree. I think this is a very thoughtful and considered development. It should go ahead",
               name: "Another Citizen")
        visit comments_path
      end

      it "passes accessibility tests", js: true do
        expect(page).to be_axe_clean
      end

      # rubocop:disable RSpec/NoExpectationExample
      it "renders the page", js: true do
        page.percy_snapshot("Recent comments")
      end
      # rubocop:enable RSpec/NoExpectationExample
    end

    describe "your comments page in profile" do
      describe "no comments yet" do
        before do
          visit comments_profile_path
        end

        it "lets the user know" do
          expect(page).to have_content("You haven't made any comments yet")
        end

        it "passes accessibility tests", js: true do
          expect(page).to be_axe_clean
        end

        # rubocop:disable RSpec/NoExpectationExample
        it "renders the page", js: true do
          page.percy_snapshot("Your comments empty")
        end
        # rubocop:enable RSpec/NoExpectationExample
      end

      describe "you have made one comment" do
        before do
          create(:published_comment,
                 text: "I am a resident the suburb. I object to the development application. My main concerns are the potential impacts on local wildlife.",
                 user: signed_in_user)
          create(:published_comment,
                 text: "I disagree. I think this is a very thoughtful and considered development. It should go ahead",
                 user: signed_in_user)
          visit comments_profile_path
        end

        it "passes accessibility tests", js: true do
          expect(page).to be_axe_clean
        end

        # rubocop:disable RSpec/NoExpectationExample
        it "renders the page", js: true do
          page.percy_snapshot("Your comments")
        end
        # rubocop:enable RSpec/NoExpectationExample
      end
    end
  end
end
