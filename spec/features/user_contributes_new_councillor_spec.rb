require "spec_helper"

feature "Contributing a new councillor for an authority" do
  let(:authority) { create(:authority, full_name: "Casey City Council") }

  scenario "on the contribution page" do
    visit new_authority_suggested_councillor_path(authority.short_name_encoded)
    expect(page).to have_content("Casey City Council")
  end

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

    it "successfully" do
      visit new_authority_suggested_councillor_path(authority.short_name_encoded)

      within_fieldset "Add a councillor" do
        fill_in "Name", with: "Mila Gilic"
        fill_in "Email", with: "mgilic@casey.vic.gov.au"
      end
      click_button "Submit"

      expect(page).to have_content "Thank you"
    end
  end
end
