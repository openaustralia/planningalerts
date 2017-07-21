require 'spec_helper'

feature "tutuorial page shows directory of council website" do
  let(:authority) { create(:authority, full_name: "Casey City Council", website_url: "https//caseycity.nsw.gov.au") }

  scenario "on the contribution tutorial page" do
    visit contribution_tutorial_path
    expect(page).to have_button("Search")
  end

end
