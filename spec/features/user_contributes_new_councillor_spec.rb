require "spec_helper"

feature "Contributing a new councillor for an authority" do
  let(:authority) { create(:authority, full_name: "Casey City Council") }

  it "successfully" do
    visit new_authority_suggested_councillor_path(authority)

    within_fieldset "Add a councillor" do
      fill_in "Name", with: "Mila Gilic"
      fill_in "Email", with: "mgilic@casey.vic.gov.au"
    end
    click_button "Submit"

    expect(page).to have_content "Thank you"
  end
end
