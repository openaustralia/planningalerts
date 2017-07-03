require "spec_helper"

feature "Contributing a new councillor for an authority" do
  let(:authority) { create(:authority, full_name: "Casey City Council") }

  context "when the feature flag is off" do
    it "isn't available" do
      visit new_authority_suggested_councillor_path(authority.short_name_encoded)

      expect(page.status_code).to eq 404
    end
  end

  context "when the feature flag is on" do
    around do |test|
      with_modified_env CONTRIBUTE_COUNCILLORS_ENABLED: "true" do
        test.run
      end
    end

    scenario "on the contribution page" do
      visit new_authority_suggested_councillor_path(authority.short_name_encoded)

      expect(page).to have_content("Casey City Council")
    end

    it "works successfully when the contributor provides their information" do
      visit new_authority_suggested_councillor_path(authority.short_name_encoded)

      within_fieldset "Add a councillor" do
        fill_in "Name", with: "Mila Gilic"
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

    it "works successfully without contributor information" do
      visit new_authority_suggested_councillor_path(authority.short_name_encoded)

      within_fieldset "Add a councillor" do
        fill_in "Name", with: "Mila Gilic"
        fill_in "Email", with: "mgilic@casey.vic.gov.au"
      end

      click_button "Add another councillor"

      expect(page).to have_content "Mila Gilic"
      expect(page).to have_content "mgilic@casey.vic.gov.au"

      within_fieldset "Add a councillor" do
        fill_in "Name", with: "Rosalie Crestani"
        fill_in "Email", with: "rcrestani@casey.vic.gov.au"
      end

      click_button "Submit"

      expect(page).to have_content "Thank you"
    end
  end
end
