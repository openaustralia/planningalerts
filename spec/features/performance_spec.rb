require "spec_helper"

feature "Viewing total the number of individual subscribers" do
  background do
    create(:confirmed_alert, email: "mary@example.org")
    create(:confirmed_alert, email: "mary@example.org")
    create(:confirmed_alert, email: "mary@example.org")
    create(:confirmed_alert, email: "clare@example.org")
    create(:confirmed_alert, email: "clare@example.org")
    create(:confirmed_alert, email: "zou@example.org")
    create(:confirmed_alert, email: "henare@example.org")
    create(:confirmed_alert, email: "kat@example.org")
    create(:confirmed_alert, email: "micaela@example.org")
    create(:confirmed_alert, email: "matthew@example.org")
    create(:confirmed_alert, email: "jason@example.org")
    create(:confirmed_alert, email: "luke@example.org")
    create(:confirmed_alert, email: "daniel@example.org")
    create(:unconfirmed_alert, email: "emily@example.org")
  end

  scenario "successfully" do
    visit performance_index_path

    expect(page).to have_content "10 people are signed up for PlanningAlerts"
  end
end

feature "Viewing the use of the comments function" do
  before :each do
    Timecop.freeze(Time.utc(2016, 1, 5, 10))
  end

  after :each do
    Timecop.return
  end

  context "when there are no comments" do
    scenario "Viewing the table showing commenters per day" do
      visit performance_index_path
      expect(page).to have_content "New and returning people commenting on applications each day"
      expect(page).to_not have_content "#{Time.current.to_date} 0 0"
      expect(page).to have_content "#{1.day.ago.to_date} 0 0"
      expect(page).to have_content "#{3.days.ago.to_date} 0 0"
      expect(page).to have_content "#{4.days.ago.to_date} 0 0"
      expect(page).to have_content "#{3.months.ago.to_date} 0 0"
    end
  end

  context "when there are comments" do
    background do
      VCR.use_cassette("planningalerts", allow_playback_repeats: true) do
        create(:confirmed_comment, confirmed_at: Time.current.to_date, email: "foo@example.com")
        create(:confirmed_comment, confirmed_at: Time.current.to_date, email: "bar@example.com")
        create(:confirmed_comment, confirmed_at: 3.days.ago, email: "foo@example.com")
        create(:confirmed_comment, confirmed_at: 3.days.ago, email: "bar@example.com")
        create(:confirmed_comment, confirmed_at: 3.days.ago, email: "zap@example.com")
        create(:confirmed_comment, confirmed_at: 4.days.ago.to_date, email: "foo@example.com")
        create(:confirmed_comment, confirmed_at: 4.days.ago.to_date, email: "bar@example.com")
        create(:confirmed_comment, confirmed_at: 4.days.ago.to_date, email: "wiz@example.com")
      end
    end

    scenario "Viewing the table showing commenters per day" do
      visit performance_index_path
      expect(page).to have_content "New and returning people commenting on applications each day"
      expect(page).to_not have_content "#{Time.current.to_date} 0 2"
      expect(page).to have_content "#{1.day.ago.to_date} 0 0"
      expect(page).to have_content "#{3.days.ago.to_date} 1 2"
      expect(page).to have_content "#{4.days.ago.to_date} 3 0"
      expect(page).to have_content "#{3.months.ago.to_date} 0 0"
    end
  end
end
