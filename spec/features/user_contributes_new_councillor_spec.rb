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

    context "with three councillors" do
      before do
        visit new_authority_councillor_contribution_path(authority.short_name_encoded)

        within "fieldset" do
          fill_in "Full name", with: "Mila Gilic"
          fill_in "Email", with: "mgilic@casey.vic.gov.au"
        end

        click_button "Add another councillor"

        within(page.all("fieldset")[1]) do
          fill_in "Full name", with: "Susan Serey"
          fill_in "Email", with: "ssurey@casey.vic.gov.au"
        end

        click_button "Add another councillor"

        within(page.all("fieldset")[2]) do
          fill_in "Full name", with: "Rosalie Crestani"
          fill_in "Email", with: "rcrestani@casey.vic.gov.au"
        end

        click_button "Submit 3 new councillors"
      end

      context "and skipping source information" do
        before do
          click_button "Submit"
        end

        it "successfully" do
          expect(page).to have_content "Who do we thank?"
        end
      end

      context ", providing source information" do
        before do
          fill_in "Let us know where you found this information", with: "https//caseycitycouncil.nsw.gov.au"

          click_button "Submit"
        end

      context "and providing contributor details" do
        before do
          fill_in "Your name", with: "Jane Contributes"
          fill_in "Your email", with: "jane@contributor.com"

          click_button "Submit"
        end

        it "successfully" do
          expect(page).to have_content "Thank you for this great contribution of 3 new Casey City Council Councillors"
          expect(CouncillorContribution.first.contributor.name).to eq "Jane Contributes"
        end
      end
        context "and skiping contributor details" do
          before do
            click_button "I'd rather not say"
          end

          it "successfully" do
            expect(page).to have_content "Thank you for this great contribution of 3 new Casey City Council Councillors"
            expect(Contributor.count).to be_zero
          end
        end
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

        within(page.all("fieldset")[1]) do
          fill_in "Full name", with: "Rosalie Crestani"
          fill_in "Email", with: "rcrestani@casey.vic.gov.au"
        end

        click_button "Add another councillor"

        within(page.all("fieldset")[2]) do
          fill_in "Full name", with: "Rosalie Crestani"
          fill_in "Email", with: "rcrestani@casey.vic.gov.au"
        end

        click_button "Add another councillor"

        click_button "Submit 4 new councillors"

        fill_in "Let us know where you found this information", with: "https//caseycitycouncil.nsw.gov.au"

        click_button "Submit"
      end

      # TODO: This really should return the blank councillor as invalid.
      #       but the person then needs a way to remove it if they added the
      #       extra councillor by accident and they don't want to submit it.
      #       Remove this once the two in exchange for the two pending tests below.
      it "successfully" do
        expect(page).to have_content "Who do we thank?"
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

    it "successfully with councillors being edited after they're first added" do
      visit new_authority_councillor_contribution_path(authority.short_name_encoded)

      within(page.all("fieldset").first) do
        fill_in "Full name", with: "Original Councillor"
        fill_in "Email", with: "ngelic@casey.vic.gov.au"
      end

      click_button "Add another councillor"

      find_field("Full name", with: "Original Councillor")
      find_field("Email", with: "ngelic@casey.vic.gov.au")

      within(page.all("fieldset").first) do
        fill_in "Full name", with: "Changed Councillor"
        fill_in "Email", with:"mgilic@casey.vic.gov.au"
      end

      click_button "Submit 2 new councillors"

      fill_in "Let us know where you found this information", with: "https//caseycitycouncil.nsw.gov.au"

      click_button "Submit"

      expect(page).to have_content "Who do we thank?"
      expect(SuggestedCouncillor.find_by(name: "Original Councillor")).to be_nil
      expect(SuggestedCouncillor.find_by(name: "Changed Councillor")).to be_present
    end

    it "admin receives notification email for councillor contribution" do
      admin = create(:admin)

      visit new_authority_councillor_contribution_path(authority.short_name_encoded)

      within "fieldset" do
        fill_in "Full name", with: "Mila Gilic"
        fill_in "Email", with: "mgilic@casey.vic.gov.au"
      end

      click_button "Submit 1 new councillor"

      fill_in "Let us know where you found this information", with: "https//caseycitycouncil.nsw.gov.au"

      click_button "Submit"

      expect(unread_emails_for("moderator@planningalerts.org.au").size).to eq 1

      open_email("moderator@planningalerts.org.au")

      expect(current_email).to have_content("Casey City Council")

      click_first_link_in_email

      within("#new_user") do
        fill_in "Email", with: admin.email
        fill_in "Password", with: admin.password
      end

      click_button "Sign in"

      expect(page).to have_content("Mila Gilic")
    end
  end
end
