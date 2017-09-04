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

    context "when a person submits one councillor with all blank attributes" do
      before :each do
        visit new_authority_councillor_contribution_path(authority.short_name_encoded)

        within ".councillor-contribution-councillors fieldset" do
          fill_in "Full name", with: ""
          fill_in "Email", with: ""
        end

        click_button "Submit"
      end

      it "does not go to the contributor information page" do
        expect(page).to have_content "Who are the elected councillors for Casey City Council?"
      end
    end

    context "with three councillors and one blank councillor" do
      before :each do
        visit new_authority_councillor_contribution_path(authority.short_name_encoded)

        within "fieldset" do
          fill_in "Full name", with: "Mila Gilic"
          fill_in "Email", with: "mgilic@casey.vic.gov.au"
        end

        click_button "Add another councillor"

        within "fieldset:nth-child(2)" do
          fill_in "Full name", with: "Rosalie Crestani"
          fill_in "Email", with: "rcrestani@casey.vic.gov.au"
        end

        click_button "Add another councillor"

        within "fieldset:nth-child(3)" do
          fill_in "Full name", with: "Rosalie Crestani"
          fill_in "Email", with: "rcrestani@casey.vic.gov.au"
        end

        click_button "Add another councillor"

        click_button "Submit 4 new councillors"
      end

      # TODO: This really should return the blank councillor as invalid.
      #       but the person then needs a way to remove it if they added the
      #       extra councillor by accident and they don't want to submit it.
      #       Remove this once the two in exchange for the two pending tests below.
      it "successfully" do
        expect(page).to have_content "Thank you"
      end

      it "displays an error message" do
        pending("this is yet to be implemented, it needs to be clear to people what to do if they accidentally add an extra councillor fieldset before we prevent a blank one from being submitted")
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Email can't be blank")
      end

      it "does not go to the contributor information page" do
        pending("this is yet to be implemented, it needs to be clear to people what to do if they accidentally add an extra councillor fieldset before we prevent a blank one from being submitted")
        expect(page).to have_content "Add a new councillor for Casey City Council"
      end
    end

    it "successfully with three councillors" do
      visit new_authority_councillor_contribution_path(authority.short_name_encoded)

      within "fieldset" do
        fill_in "Full name", with: "Mila Gilic"
        fill_in "Email", with: "mgilic@casey.vic.gov.au"
      end

      click_button "Add another councillor"

      within "fieldset:nth-child(2)" do
        fill_in "Full name", with: "Rosalie Crestani"
        fill_in "Email", with: "rcrestani@casey.vic.gov.au"
      end

      click_button "Add another councillor"

      within "fieldset:nth-child(3)" do
        fill_in "Full name", with: "Rosalie Crestani"
        fill_in "Email", with: "rcrestani@casey.vic.gov.au"
      end

      click_button "Submit 3 new councillors"

      expect(page).to have_content "Thank you"
    end

    it "successfully with councillors being edited after they're first added" do
      visit new_authority_councillor_contribution_path(authority.short_name_encoded)

      within "fieldset:first-child" do
        fill_in "Full name", with: "Original Councillor"
        fill_in "Email", with: "ngelic@casey.vic.gov.au"
      end

      click_button "Add another councillor"

      find_field("Full name", with: "Original Councillor")
      find_field("Email", with: "ngelic@casey.vic.gov.au")

      within "fieldset:first-child" do
        fill_in "Full name", with: "Changed Councillor"
        fill_in "Email", with:"mgilic@casey.vic.gov.au"
      end

      click_button "Submit 2 new councillors"

      expect(page).to have_content "Thank you"
      expect(SuggestedCouncillor.find_by(name: "Original Councillor")).to be_nil
      expect(SuggestedCouncillor.find_by(name: "Changed Councillor")).to be_present
    end
  end
end
