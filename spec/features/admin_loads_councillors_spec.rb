require "spec_helper"

feature "Admin loads councillors for an authority" do
  given(:authority) { create(:authority,
                             full_name: "Marrickville Council",
                             state: "NSW") }

  scenario "successfully" do
    sign_in_as_admin

    visit admin_authority_path(authority)

    VCR.use_cassette("australian_local_councillors_popolo") do
      click_button "Load Councillors"
    end

    expect(page).to have_content "Successfully loaded councillors"
    expect(page).to have_content "Max Phillips"
    expect(page).to have_content "Chris Woods"
  end

  context "when the authority is from another state" do
    given(:qld_authority) { create(:authority,
                                   full_name: "Toowoomba Regional Council",
                                   state: "QLD") }

    scenario "successfully" do
      sign_in_as_admin

      visit admin_authority_path(qld_authority)

      VCR.use_cassette("australian_local_councillors_popolo") do
        click_button "Load Councillors"
      end

      expect(page).to have_content "Successfully loaded councillors"
      expect(page).to have_content "Sue Englart"
      expect(page).to have_content "John Gouldson"
    end
  end
end
