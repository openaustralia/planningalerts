require "spec_helper"

feature "Contributing new councillors for an authority" do
  let(:authority) { create(:authority, full_name: "Casey City Council") }

  context "when the feature flag is off" do
    it "isn't available" do
      visit new_authority_councillor_contribution_path(authority.short_name_encoded)

      expect(page.status_code).to eq 404
    end
  end

  context "when the feature flag is on" do
    around do |test|
      with_modified_env CONTRIBUTE_COUNCILLORS_ENABLED: "true" do
        test.run
      end
    end

    it "after landing on the contribution page, works successfully when the contributor provides their information" do
      visit new_authority_councillor_contribution_path(authority.short_name_encoded)

      within ".councillor-contribution-councillors fieldset" do
        fill_in "Full name", with: "Mila Gilic"
        fill_in "Email", with: "mgilic@casey.vic.gov.au"
      end

      click_button "Submit"

      within_fieldset "Please tell us about yourself, so we can send you a little note of appreciation and updates about your contribution when it goes live." do
        fill_in "Name", with: "Jane Contributes"
        fill_in "Email", with: "jane@contributor.com"
      end

      click_button "Submit"

      expect(page).to have_content "Thank you"
    end

    it "works successfully when the contributor does not provide their information" do
      visit new_authority_councillor_contribution_path(authority.short_name_encoded)

      within ".councillor-contribution-councillors fieldset" do
        fill_in "Full name", with: "Mila Gilic"
        fill_in "Email", with: "mgilic@casey.vic.gov.au"
      end

      click_button "Add another councillor"

      expect(page).to have_content "Mila Gilic"
      expect(page).to have_content "mgilic@casey.vic.gov.au"

      within ".councillor-contribution-councillors fieldset" do
        fill_in "Full name", with: "Rosalie Crestani"
        fill_in "Email", with: "rcrestani@casey.vic.gov.au"
      end

      click_button "Submit"

      expect(page).to have_content "Thank you"
    end

    it "successfully with three councillors and one blank councillor" do
      visit new_authority_councillor_contribution_path(authority.short_name_encoded)

      within ".councillor-contribution-councillors fieldset" do
        fill_in "Full name", with: "Mila Gilic"
        fill_in "Email", with: "mgilic@casey.vic.gov.au"
      end

      click_button "Add another councillor"

      within ".councillor-contribution-councillors fieldset" do
        fill_in "Full name", with: "Rosalie Crestani"
        fill_in "Email", with: "rcrestani@casey.vic.gov.au"
      end

      click_button "Add another councillor"

      within ".councillor-contribution-councillors fieldset" do
        fill_in "Full name", with: "Rosalie Crestani"
        fill_in "Email", with: "rcrestani@casey.vic.gov.au"
      end

      click_button "Add another councillor"

      click_button "Submit 4 new councillors"

      expect(page).to have_content "Thank you"

    end

    it "successfully with three councillors" do
      visit new_authority_councillor_contribution_path(authority.short_name_encoded)

      within ".councillor-contribution-councillors fieldset" do
        fill_in "Full name", with: "Mila Gilic"
        fill_in "Email", with: "mgilic@casey.vic.gov.au"
      end

      click_button "Add another councillor"

      within ".councillor-contribution-councillors fieldset" do
        fill_in "Full name", with: "Rosalie Crestani"
        fill_in "Email", with: "rcrestani@casey.vic.gov.au"
      end

      click_button "Add another councillor"

      within ".councillor-contribution-councillors fieldset" do
        fill_in "Full name", with: "Rosalie Crestani"
        fill_in "Email", with: "rcrestani@casey.vic.gov.au"
      end

      click_button "Submit 3 new councillors"

      expect(page).to have_content "Thank you"

    end
  end
end
