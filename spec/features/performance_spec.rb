require 'spec_helper'

feature "Viewing total the number of individual subscribers" do
  background do
    mary = create(:alert_subscriber, email: "mary@example.org")
    clare = create(:alert_subscriber, email: "clare@example.org")
    zou = create(:alert_subscriber, email: "zou@example.org")
    henare = create(:alert_subscriber, email: "henare@example.org")
    kat = create(:alert_subscriber, email: "kat@example.org")
    micaela = create(:alert_subscriber, email: "micaela@example.org")
    mattew = create(:alert_subscriber, email: "mattew@example.org")
    jason = create(:alert_subscriber, email: "jason@example.org")
    luke = create(:alert_subscriber, email: "luke@example.org")
    daniel = create(:alert_subscriber, email: "daniel@example.org")
    emily = create(:alert_subscriber, email: "emily@example.org")

    create(:confirmed_alert, alert_subscriber: mary)
    create(:confirmed_alert, alert_subscriber: mary)
    create(:confirmed_alert, alert_subscriber: mary)
    create(:confirmed_alert, alert_subscriber: clare)
    create(:confirmed_alert, alert_subscriber: clare)
    create(:confirmed_alert, alert_subscriber: zou)
    create(:confirmed_alert, alert_subscriber: henare)
    create(:confirmed_alert, alert_subscriber: kat)
    create(:confirmed_alert, alert_subscriber: micaela)
    create(:confirmed_alert, alert_subscriber: mattew)
    create(:confirmed_alert, alert_subscriber: jason)
    create(:confirmed_alert, alert_subscriber: luke)
    create(:confirmed_alert, alert_subscriber: daniel)
    create(:unconfirmed_alert, alert_subscriber: emily)
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
      VCR.use_cassette('planningalerts', allow_playback_repeats: true) do
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
