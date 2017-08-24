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
  context "when the feature flag is on" do
    around do |test|
      with_modified_env CONTRIBUTE_COUNCILLORS_ENABLED: "true" do
        test.run
      end
    end

      scenario "on the contribution tutorial page" do
        visit contribution_tutorial_path
        expect(page).to have_content("Casey City Council")
      end
    end
  end
end
