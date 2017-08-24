require 'spec_helper'

feature "tutuorial page shows directory of council website" do
  background do
    create(:authority, full_name: "Casey City Council", website_url: "https//caseycity.nsw.gov.au")
  end

  context "when the feature flag is off" do
    it "isn't available" do
      visit contribution_tutorial_path
      expect(page.status_code).to eq 404
    end
  end
  
  context "when the feature flag is on," do
    around do |test|
      with_modified_env CONTRIBUTE_COUNCILLORS_ENABLED: "true" do
        test.run
      end
    end

      scenario "on the contribution tutorial page" do
        visit contribution_tutorial_path
        expect(page).to have_content("Casey City Council")
      end

      scenario "the search matches with existing council" do
        visit contribution_tutorial_path
          fill_in "Council name", with: "Casey City Council"
          click_button "Search"
        expect(page).to have_content("Casey City Council")
      end

      scenario "the search bar is empty" do
        visit contribution_tutorial_path
          fill_in "Council name", with: ""
          click_button "Search"
        expect(page).to have_content("Sorry, no results found!")
      end

      scenario "there is no search result" do
        visit contribution_tutorial_path
          fill_in "Council name", with: "Marrickvelle"
          click_button "Search"
        expect(page).to have_content("Sorry, no results found!")
      end
    end
  end
