require "spec_helper"

feature "Contributor can contribute their contact information" do
  context "when the feature flag is off" do
    it "isn't available" do
      visit new_contributor_path

      expect(page.status_code).to eq 404
    end
  end

  context "when the feature flag is on" do
    around do |test|
      with_modified_env CONTRIBUTE_COUNCILLORS_ENABLED: "true" do
        test.run
      end
    end

    before :each do
      CouncillorContribution.new(id: 1).save
    end

    it "successfully" do
      visit new_contributor_path(councillor_contribution_id: 1)

      within_fieldset "Please tell us about yourself, so we can send you a little note of appreciation and updates about your contribution when it goes live." do
        fill_in "Name", with: "Jane Contributes"
        fill_in "Email", with: "jane@contributor.com"
      end

      click_button "Submit"

      expect(page).to have_content "Thank you"
    end

    it "or not if they choose" do
      visit new_contributor_path(councillor_contribution_id: 1)

      click_link "I prefer not to"

      expect(page).to have_content "Thank you"
    end
  end
end
