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

    fill_in("alert_email", with: "example@example.com")
    fill_in("alert_address", with: "24 Bruce Rd, Glenbrook")
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

  def confirm_alert_in_email
    open_email("example@example.com")
    expect(current_email).to have_subject("Please confirm your planning alert")
    expect(current_email.default_part_body.to_s).to include("24 Bruce Rd, Glenbrook NSW 2773")
    click_first_link_in_email
  end
end
