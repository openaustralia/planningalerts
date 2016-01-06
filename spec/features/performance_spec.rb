require 'spec_helper'

feature "Viewing the use of the comments function" do
  context "when there are no comments" do
    scenario "Viewing the table showing commenters per day" do
      visit performance_index_path
      expect(page).to have_content "New and returning people commenting on applications over time"
      expect(page).to have_content "#{Date.today} 0 0"
      expect(page).to have_content "#{Date.yesterday} 0 0"
      expect(page).to have_content "#{3.days.ago.to_date} 0 0"
      expect(page).to have_content "#{4.days.ago.to_date} 0 0"
      expect(page).to have_content "#{3.months.ago.to_date} 0 0"
    end
  end

  context "when there are comments" do
    background do
      VCR.use_cassette('planningalerts', allow_playback_repeats: true) do
        create(:confirmed_comment, created_at: Date.today, email: "foo@example.com")
        create(:confirmed_comment, created_at: Date.today, email: "bar@example.com")
        create(:confirmed_comment, created_at: 3.days.ago, email: "foo@example.com")
        create(:confirmed_comment, created_at: 3.days.ago, email: "bar@example.com")
        create(:confirmed_comment, created_at: 3.days.ago, email: "zap@example.com")
        create(:confirmed_comment, created_at: 4.days.ago.to_date, email: "foo@example.com")
        create(:confirmed_comment, created_at: 4.days.ago.to_date, email: "bar@example.com")
        create(:confirmed_comment, created_at: 4.days.ago.to_date, email: "wiz@example.com")
      end
    end

    scenario "Viewing the table showing commenters per day" do
      visit performance_index_path
      expect(page).to have_content "New and returning people commenting on applications over time"
      expect(page).to have_content "#{Date.today} 0 2"
      expect(page).to have_content "#{Date.yesterday} 0 0"
      expect(page).to have_content "#{3.days.ago.to_date} 1 2"
      expect(page).to have_content "#{4.days.ago.to_date} 3 0"
      expect(page).to have_content "#{3.months.ago.to_date} 0 0"
    end
  end
end
