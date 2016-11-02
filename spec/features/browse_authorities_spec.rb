require 'spec_helper'

feature "Browse authorities" do
  # In order to understand if this tool will help me
  # As a citizen
  # I want to see what authorities are covered

  scenario "Browsing the list of authories seeing state headings and authority links" do
    nsw_auth = create(:authority, state: 'NSW')
    vic_auth = create(:authority, state: 'VIC')

    VCR.use_cassette('planningalerts') do
      visit(authorities_path)
    end

    expect(page).to have_selector("h4#nsw", :text => "NSW")
    expect(page).to have_selector('ul.authorities li a', :text => nsw_auth.full_name)
    expect(page).to have_selector("h4#vic", :text => "VIC")
    expect(page).to have_selector('ul.authorities li a', :text => vic_auth.full_name)
  end


end