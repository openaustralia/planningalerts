# frozen_string_literal: true

require "spec_helper"

describe "Authorities" do
  include Devise::Test::IntegrationHelpers

  describe "detail page for an authority that is not covered in the new design" do
    before do
      # Give a name to the user so screenshots are consistent with percy
      sign_in create(:confirmed_user, tailwind_theme: true, name: "Jane Ng")
      authority = create(:authority, full_name: "Byron Shire Council")
      visit authority_path(authority.short_name_encoded)
    end

    it "explains why the authority isn't covered yet" do
      expect(page).to have_content("This authority is not yet covered by Planning Alerts")
    end

    describe "accessibility test", js: true do
      it "passes" do
        expect(page).to be_axe_clean
      end
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", js: true do
      page.percy_snapshot("Authority not covered")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe "detail page for an authority in the new design" do
    before do
      # Give a name to the user so screenshots are consistent with percy
      sign_in create(:confirmed_user, tailwind_theme: true, name: "Jane Ng")
      authority = create(:authority, full_name: "Byron Shire Council", morph_name: "planningalerts-scrapers/byron")
      # We need it to have at least one application so it's not "broken"
      # TODO: I suspect we'll need to lock down the date of the application so that percy snapshots are consistent
      create(:geocoded_application, authority:, council_reference: "1", date_scraped: Date.new(2020, 1, 1))
      create(:geocoded_application, authority:, council_reference: "2", date_scraped: Date.new(2020, 1, 8))
      create(:geocoded_application, authority:, council_reference: "3", date_scraped: Date.new(2020, 1, 15))
      Timecop.freeze(Date.new(2020, 1, 22)) do
        visit authority_path(authority.short_name_encoded)
      end
    end

    describe "accessibility test", js: true do
      it "passes" do
        expect(page).to be_axe_clean
      end
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", js: true do
      # Wait for javascript graph drawing to finish
      find("#applications-chart .chart-line.chart-clipping-above")
      find("#comments-chart .chart-line.chart-clipping-above")
      page.percy_snapshot("Authority")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe "detail page for a covered authority with no applications in the new design" do
    before do
      # Give a name to the user so screenshots are consistent with percy
      sign_in create(:confirmed_user, tailwind_theme: true, name: "Jane Ng")
      authority = create(:authority, full_name: "Byron Shire Council", morph_name: "planningalerts-scrapers/byron")
      visit authority_path(authority.short_name_encoded)
    end

    it "lets the user know that there are no applications" do
      expect(page).to have_content("No applications have yet been collected")
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", js: true do
      page.percy_snapshot("Authority no applications")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end

  describe "detail page for an authority with a broken scraper in the new design" do
    before do
      # Give a name to the user so screenshots are consistent with percy
      sign_in create(:confirmed_user, tailwind_theme: true, name: "Jane Ng")
      authority = create(:authority, full_name: "Byron Shire Council", morph_name: "planningalerts-scrapers/byron")
      # We need it to have at least one application so it's not "broken"
      # TODO: I suspect we'll need to lock down the date of the application so that percy snapshots are consistent
      create(:geocoded_application, authority:, council_reference: "1", date_scraped: Date.new(2020, 1, 1))
      create(:geocoded_application, authority:, council_reference: "2", date_scraped: Date.new(2020, 1, 8))
      create(:geocoded_application, authority:, council_reference: "3", date_scraped: Date.new(2020, 1, 15))
      # This date is more than 2 week after the latest application
      Timecop.freeze(Date.new(2020, 2, 1)) do
        visit authority_path(authority.short_name_encoded)
      end
    end

    it "lets the user know that there's a problem" do
      expect(page).to have_content("It looks like something might be wrong")
    end

    # rubocop:disable RSpec/NoExpectationExample
    it "renders the page", js: true do
      # Wait for javascript graph drawing to finish
      find("#applications-chart .chart-line.chart-clipping-above")
      find("#comments-chart .chart-line.chart-clipping-above")
      page.percy_snapshot("Authority broken scraper")
    end
    # rubocop:enable RSpec/NoExpectationExample
  end
end
