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

    context "when a person submit an invalid email" do
      before :each do
        visit new_authority_councillor_contribution_path(authority.short_name_encoded)

        within ".councillor-contribution-councillors fieldset" do
          fill_in "Full name", with: "Mila Gilic"
          fill_in "Email", with: "mgilic.invalid"
        end

        click_button "Submit"
      end

      it "displays an error message" do
        expect(page).to have_content("does not appear to be a valid e-mail address")
      end

      # FIXME: This test is passing but it's not testing what we want
      it "does not go into the list of the suggested councillors" do
        expect(page).to_not have_content("Name: Mila Gilic")
        expect(page).to_not have_content("Email: mglic.invalid")
      end

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
