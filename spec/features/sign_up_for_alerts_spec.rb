require 'spec_helper'

feature "Sign up for alerts" do
  # In order to see new development applications in my suburb
  # I want to sign up for an email alert
  around do |example|
    VCR.use_cassette('planningalerts') do
      example.run
    end
  end

  scenario "successfully" do
    visit '/alerts/signup'

    fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
    fill_in("Enter your email address", with: "example@example.com")
    click_button("Create alert")

    expect(page).to have_content("Now check your email")

    confirm_alert_in_email

    expect(page).to have_content("your alert has been activated")
    expect(page).to have_content("24 Bruce Rd, Glenbrook NSW 2773")
    expect(page).to_not have_content("You now have several email alerts")
    expect(
      Alert.active.find_by(address: "24 Bruce Rd, Glenbrook NSW 2773",
                           radius_meters: "2000",
                           email: current_email_address)
    ).to_not be_nil
  end

  scenario "unsuccessfully with an invalid address" do
    visit '/alerts/signup'

    fill_in("Enter a street address", with: "Bruce Rd")
    fill_in("Enter your email address", with: "example@example.com")

    click_button("Create alert")

    expect(page).to have_content("Please enter a full street address, including suburb and state, e.g. Bruce Rd, Millmerran QLD 4357")
  end

  context "via an application page" do
    given(:application) do
      create(:application, address: "24 Bruce Rd, Glenbrook NSW 2773")
    end

    scenario "successfully" do
      visit application_path(application)

      within "#new_alert" do
        fill_in("Enter your email address", with: "example@example.com")
        click_button("Create Alert")
      end

      expect(page).to have_content("Now check your email")

      confirm_alert_in_email

      expect(page).to have_content("your alert has been activated")
    end
  end

  context "via the homepage" do
    background do
      create(:application, address: "26 Bruce Rd, Glenbrook NSW 2773")
    end

    scenario "successfully" do
      visit root_path
      fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
      click_button("Search")

      fill_in("Enter your email address", with: "example@example.com")
      click_button("Create alert")

      expect(page).to have_content("Now check your email")

      confirm_alert_in_email

      expect(page).to have_content("your alert has been activated")
    end
  end

  context "via an authority’s applications page" do
    background do
      authority = create(:authority, short_name: "Glenbrook")
      create(:application, address: "26 Bruce Rd, Glenbrook NSW 2773", authority: authority)
    end

    scenario "successfully" do
      visit applications_path(authority_id: "glenbrook")

      fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
      fill_in("Enter your email address", with: "example@example.com")
      click_button("Create alert")

      expect(page).to have_content("Now check your email")

      confirm_alert_in_email

      expect(page).to have_content("your alert has been activated")
    end
  end

  context "when there is already an unconfirmed alert for the address" do
    around do |test|
      Timecop.freeze(DateTime.new(2017, 1, 4, 14, 35)) { test.run }
    end

    given!(:preexisting_alert) do
      create(:unconfirmed_alert, address: "24 Bruce Rd, Glenbrook NSW 2773",
                                 email: "example@example.com",
                                 created_at: 3.days.ago,
                                 updated_at: 3.days.ago)
    end

    scenario "successfully" do
      visit '/alerts/signup'

      fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
      fill_in("Enter your email address", with: "example@example.com")
      click_button("Create alert")

      expect(page).to have_content("Now check your email")

      confirm_alert_in_email

      expect(page).to have_content("your alert has been activated")
      expect(page).to have_content("24 Bruce Rd, Glenbrook NSW 2773")

      expect(preexisting_alert.reload.created_at).to eq 3.days.ago
      expect(preexisting_alert.reload.updated_at).to eq Time.current
    end
  end

  context "when there is already an confirmed alert for the address" do
    given!(:preexisting_alert) do
      create(:confirmed_alert, address: "24 Bruce Rd, Glenbrook NSW 2773",
                               email: "jenny@email.org",
                               created_at: 3.days.ago,
                               updated_at: 3.days.ago)
    end

    scenario "see the confirmation page, so we don't leak information, but also get a notice about the signup attempt" do
      visit '/alerts/signup'

      fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
      fill_in("Enter your email address", with: "jenny@email.org")
      click_button("Create alert")

      expect(page).to have_content("Now check your email")

      open_last_email_for("jenny@email.org")

      expect(current_email.default_part_body.to_s).to have_content(
        "We just received a new request to send PlanningAlerts for 24 Bruce Rd, Glenbrook NSW 2773 to your email address."
      )
    end

    context "but it is unsubscribed" do
      before do
        preexisting_alert.unsubscribe!
      end

      scenario "successfully" do
        visit '/alerts/signup'

        fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
        fill_in("Enter your email address", with: "jenny@email.org")
        click_button("Create alert")

        expect(page).to have_content("Now check your email")

        open_email("jenny@email.org")

        click_first_link_in_email

        expect(page).to have_content("your alert has been activated")
        expect(page).to have_content("24 Bruce Rd, Glenbrook NSW 2773")
      end
    end
  end

  def confirm_alert_in_email
    open_email("example@example.com")
    expect(current_email).to have_subject("Please confirm your planning alert")
    expect(current_email.default_part_body.to_s).to include("24 Bruce Rd, Glenbrook NSW 2773")
    click_first_link_in_email
  end
end
