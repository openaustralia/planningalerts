require "spec_helper"

feature "Admin views a suggested councillor" do
  before do
    create(
      :suggested_councillor,
      name: "Mila Gilic",
      email: "mgilic@casey.vic.gov.au",
      authority: create(:authority, full_name: "Casey City Council")
    )
  end

  it "successfully" do
    sign_in_as_admin

    click_link "Suggested Councillors"

    expect(page).to have_content "Casey City Council Mila Gilic mgilic@casey.vic.gov.au"
  end
end
