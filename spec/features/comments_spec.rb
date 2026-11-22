# frozen_string_literal: true

require "spec_helper"

describe "Comments pages" do
  include Devise::Test::IntegrationHelpers

  describe "in the new design" do
    let(:signed_in_user) { create(:confirmed_user, name: "Jane Ng") }

    before do
      sign_in(signed_in_user)
    end

    describe "index page" do
      let(:authority) { create(:authority, full_name: "Byron Shire Council") }
      let(:application) { create(:geocoded_application, authority:) }

      before do
        create(:published_comment,
               application:,
               text: "I am a resident the suburb. I object to the development application. My main concerns are the potential impacts on local wildlife.",
               name: "Andrew Citizen")
        create(:published_comment,
               application:,
               text: "I disagree. I think this is a very thoughtful and considered development. It should go ahead",
               name: "Another Citizen")
        visit comments_path
      end

      it "passes accessibility tests", :js do
        expect(page).to be_axe_clean
        expect(page).to have_site_layout
        expect(page).to have_no_broken_internal_links
        expect(page).to have_no_missing_assets
      end

      # rubocop:disable RSpec/NoExpectationExample
      it "renders the page", :js do
        page.percy_snapshot("Recent comments")
      end
      # rubocop:enable RSpec/NoExpectationExample
    end

    # Comment text goes through simple_format and auto_link, which use Rails'
    # HTML sanitiser, then the Sanitize gem. This tests that a sanitiser change
    # in a Rails upgrade doesn't alter how comments look.
    describe "a comment with a link, paragraphs and markup" do
      let(:application) { create(:geocoded_application) }

      before do
        create(:published_comment, application:, name: "Andrew Citizen", text: CommentExamples::WITH_MARKUP)
        visit application_path(application)
      end

      it "keeps the link, paragraphs and safe formatting, and drops the rest" do
        # Today the script's text stays (escaped) and the div splits the paragraph
        expect(CommentExamples.rendered(page.html)).to eq <<~HTML.chomp
          <p>See the plans at <a href="https://example.org/plans" rel="nofollow">https://example.org/plans</a> &amp; the <b>council's</b> report.
          <br>It's a second line.</p>

          <p>A new paragraph alert(1)</p> with a div  and 5 &lt; 6.<p></p>
        HTML
      end
    end

    describe "your comments page in profile" do
      describe "no comments yet" do
        before do
          visit personal_comments_path
        end

        it "lets the user know" do
          expect(page).to have_content("You haven't made any comments yet")
          expect(page).to have_site_layout
          expect(page).to have_no_broken_internal_links
          expect(page).to have_no_missing_assets
        end

        it "passes accessibility tests", :js do
          expect(page).to be_axe_clean
        end

        # rubocop:disable RSpec/NoExpectationExample
        it "renders the page", :js do
          page.percy_snapshot("Your comments empty")
        end
        # rubocop:enable RSpec/NoExpectationExample
      end

      describe "you have made two comments" do
        let(:authority) { create(:authority, full_name: "Byron Shire Council") }
        let(:application1) { create(:geocoded_application, address: "24 Bruce Road Glenbrook", council_reference: "27B/6", authority:) }
        let(:application2) { create(:geocoded_application, address: "351 Pacific Hwy, Coffs Harbour NSW 2450", council_reference: "001", authority:) }

        before do
          # Because we can see absolute times in the email delivery text we need to set the current time
          # to get consistent snapshots for percy.io
          Timecop.freeze(Date.new(2023, 6, 1)) do
            create(:published_comment,
                   application: application1,
                   text: "I am a resident the suburb. I object to the development application. My main concerns are the potential impacts on local wildlife.",
                   published_at: 15.minutes.ago,
                   user: signed_in_user)
            create(:delivered_comment,
                   application: application2,
                   text: "I disagree. I think this is a very thoughtful and considered development. It should go ahead",
                   published_at: 10.minutes.ago,
                   user: signed_in_user)
            create(:delivery_failed_comment,
                   application: application2,
                   text: "This message is not going to go through, is it?",
                   published_at: 5.minutes.ago,
                   user: signed_in_user)
            visit personal_comments_path
          end
        end

        it "has a comment that has been sent but not yet received" do
          expect(page).to have_content("Sent to Byron Shire Council")
        end

        it "has a comment that has been successfully received" do
          expect(page).to have_content("Delivered to Byron Shire Council")
        end

        it "has a comment that failed to be delivered" do
          expect(page).to have_content("There was a problem delivering this")
        end

        it "passes accessibility tests", :js do
          expect(page).to be_axe_clean
        end

        # rubocop:disable RSpec/NoExpectationExample
        it "renders the page", :js do
          page.percy_snapshot("Your comments")
        end
        # rubocop:enable RSpec/NoExpectationExample
      end
    end
  end
end
