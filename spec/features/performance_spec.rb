require 'spec_helper'

feature "Viewing the use of the comments function" do
  context "when there are no comments" do
    scenario "Viewing the table showing commenters per day" do
      visit performance_path
      expect(page).to_not have_content "The number of people who have commented on development applications by date"
      expect(page).to have_content "Nobody has commented on an application yet"
    end
  end

  context "when there are comments" do
    background do
      VCR.use_cassette('planningalerts', allow_playback_repeats: true) do
        create(:comment, id: 1, confirmed: true, created_at: "2015-09-22", email: "foo@example.com")
        create(:comment, id: 2, confirmed: true, created_at: "2015-09-22", email: "bar@example.com")
        create(:comment, id: 3, confirmed: true, created_at: "2015-09-19", email: "foo@example.com")
        create(:comment, id: 4, confirmed: true, created_at: "2015-09-19", email: "bar@example.com")
        create(:comment, id: 5, confirmed: true, created_at: "2015-09-19", email: "zap@example.com")
        create(:comment, id: 6, confirmed: true, created_at: "2015-09-18", email: "foo@example.com")
        create(:comment, id: 7, confirmed: true, created_at: "2015-09-18", email: "bar@example.com")
        create(:comment, id: 8, confirmed: true, created_at: "2015-09-18", email: "wiz@example.com")
      end
    end

    scenario "Viewing the table showing commenters per day" do
      visit performance_path
      expect(page).to have_content "The number of people who have commented on development applications by date"
      expect(page).to have_content "2015-09-22 0 2"
      expect(page).to have_content "2015-09-19 1 2"
      expect(page).to have_content "2015-09-18 3 0"
    end
  end
end
