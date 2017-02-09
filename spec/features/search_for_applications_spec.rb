require "spec_helper"

feature "Searching for development application near an address" do
  around do |scenario|
    VCR.use_cassette('planningalerts') do
      scenario.run
    end
  end

  background do
    create(:application,
            address: "24 Bruce Road Glenbrook",
            description: "A lovely house")
  end

  scenario "successfully" do
    visit root_path

    fill_in "Enter a street address", with: "24 Bruce Road, Glenbrook"
    click_button "Search"

    expect(page).to have_content "Applications within 2 km of 24 Bruce Road, Glenbrook NSW 2773"

    within "ol.applications" do
      expect(page).to have_content "24 Bruce Road"
      expect(page).to have_content "A lovely house"
    end
  end

  context "with javascript" do
    before do
      # This is a hack to get around the ssl_required? method in
      # the application controller which redirects poltergeist to https.
      allow(Rails.env).to receive(:development?).and_return true
    end

    scenario "autocomplete results are displayed", js: true do
      visit root_path

      fill_in "Enter a street address", with: "24 Bruce R"

      # this simulates focusing on the input field, which triggers the autocomplete search
      page.execute_script("el = document.querySelector('#q');
                           event = document.createEvent('HTMLEvents');
                           event.initEvent('focus', false, true);
                           el.dispatchEvent(event);")

      # Confirm that the suggested addresses appear.
      # Is this a too brittle? It'll fail if the address format changes.
      within ".pac-container" do
        expect(page).to have_content "Bruce Road, Glenbrook, New South Wales"
      end

      # TODO: Actually test clicking the suggestion and seeing results
    end
  end
end
