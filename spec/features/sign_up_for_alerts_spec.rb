# frozen_string_literal: true

require "spec_helper"

describe "Sign up for alerts" do
  # In order to see new development applications in my suburb
  # I want to sign up for an email alert

  before do
    # It's more elegant to mock out the geocoder rather than using VCR
    g = GeocodedLocation.new(
      lat: -33.772607,
      lng: 150.624245,
      suburb: "Glenbrook",
      state: "NSW",
      postcode: "2773",
      full_address: "24 Bruce Rd, Glenbrook NSW 2773"
    )
    allow(GoogleGeocodeService).to receive(:call).with("24 Bruce Rd, Glenbrook").and_return(GeocoderResults.new([g], nil))
    allow(GoogleGeocodeService).to receive(:call).with("24 Bruce Rd, Glenbrook NSW 2773").and_return(GeocoderResults.new([g], nil))
    allow(GoogleGeocodeService).to receive(:call).with("Bruce Rd").and_return(
      GeocoderResults.new([], "Please enter a full street address, including suburb and state, e.g. Bruce Rd, Victoria")
    )
  end

  it "successfully" do
    visit "/alerts/signup"

    fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
    fill_in("Enter your email address", with: "example@example.com")
    click_button("Create alert")

    expect(page).to have_content("Now check your email")
    expect(page).to have_content("Return to applications near 24 Bruce Rd, Glenbrook")

    confirm_alert_in_email

    expect(page).to have_content("your alert has been activated")
    expect(page).to have_content("24 Bruce Rd, Glenbrook NSW 2773")
    expect(page).not_to have_content("You now have several email alerts")
    expect(
      Alert.active.find_by(address: "24 Bruce Rd, Glenbrook NSW 2773",
                           radius_meters: "2000",
                           user: User.find_by(email: current_email_address))
    ).not_to be_nil
  end

  it "unsuccessfully with an invalid address" do
    visit "/alerts/signup"

    fill_in("Enter a street address", with: "Bruce Rd")
    fill_in("Enter your email address", with: "example@example.com")

    click_button("Create alert")

    # I think because of the way geokit works we can return different alternative
    # addresses (each of which is equally sensible)
    # even though google is returning the same result (via vcr)
    expect(page).to have_content(/Please enter a full street address, including suburb and state, e.g. Bruce Rd, Victoria/)
  end

  context "when via an application page" do
    let(:application) do
      create(:geocoded_application, address: "24 Bruce Rd, Glenbrook NSW 2773")
    end

    it "successfully" do
      visit application_path(application)

      within "#new_alert" do
        fill_in("Enter your email address", with: "example@example.com")
        click_button("Create alert")
      end

      expect(page).to have_content("Now check your email")
      expect(page).to have_content("Return to applications near 24 Bruce Rd, Glenbrook")

      confirm_alert_in_email

      expect(page).to have_content("your alert has been activated")
    end
  end

  context "when via the homepage" do
    before do
      create(:geocoded_application,
             address: "26 Bruce Rd, Glenbrook NSW 2773",
             lat: -33.772812, lng: 150.624252)
    end

    it "successfully" do
      visit root_path
      fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
      click_button("Search")

      fill_in("Enter your email address", with: "example@example.com")
      click_button("Create alert")

      expect(page).to have_content("Now check your email")
      expect(page).to have_content("Return to applications near 24 Bruce Rd, Glenbrook")

      confirm_alert_in_email

      expect(page).to have_content("your alert has been activated")
    end
  end

  context "with force login feature flag set" do
    before do
      Flipper.enable(:force_login_to_comment)
    end

    context "when via the homepage" do
      before do
        create(:geocoded_application, address: "26 Bruce Rd, Glenbrook NSW 2773", lat: -33.772812, lng: 150.624252)
        create(:confirmed_user, email: "example@example.com", password: "mypassword")
      end

      it "when not logged in to start with" do
        visit root_path
        fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
        click_button("Search")

        expect(page).to have_content("Applications within 2 kilometres of 24 Bruce Rd, Glenbrook NSW 2773")
        expect(page).to have_content("Create an account or sign in to create an alert.")
        click_link("sign in")

        fill_in("Your email", with: "example@example.com")
        fill_in("Password", with: "mypassword")
        click_button("Sign in")

        expect(page).to have_content("Signed in successfully.")
        # We should be back at the same page from where we clicked "sign in"
        expect(page).to have_content("Applications within 2 kilometres of 24 Bruce Rd, Glenbrook NSW 2773")
        click_button("Create alert")

        expect(page).to have_content("You succesfully added a new alert for 24 Bruce Rd, Glenbrook NSW 2773")
      end
    end
  end

  context "when via an authority’s applications page" do
    before do
      authority = create(:authority, short_name: "Glenbrook")
      create(:geocoded_application, address: "26 Bruce Rd, Glenbrook NSW 2773", authority: authority)
    end

    it "successfully" do
      visit applications_path(authority_id: "glenbrook")

      fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
      fill_in("Enter your email address", with: "example@example.com")
      click_button("Create alert")

      expect(page).to have_content("Now check your email")
      expect(page).to have_content("Return to applications near 24 Bruce Rd, Glenbrook")

      confirm_alert_in_email

      expect(page).to have_content("your alert has been activated")
    end

    # Having trouble getting this to work. I think the autocomplete
    # web requests are not getting captured by VCR
    # context "with javascript" do
    #   scenario "autocomplete results are displayed", js: true do
    #     visit applications_path(authority_id: "glenbrook")
    #
    #     fill_in "Enter a street address", with: "24 Bruce Road Glenb"
    #
    #     expect_autocomplete_suggestions_to_include "Bruce Road, Glenbrook NSW"
    #   end
    # end
  end

  context "when there is already an unconfirmed alert for the address" do
    around do |test|
      Timecop.freeze(Time.utc(2017, 1, 4, 14, 35)) { test.run }
    end

    let!(:preexisting_alert) do
      create(:unconfirmed_alert, address: "24 Bruce Rd, Glenbrook NSW 2773",
                                 user: create(:confirmed_user, email: "example@example.com"),
                                 created_at: 3.days.ago,
                                 updated_at: 3.days.ago)
    end

    it "successfully" do
      visit "/alerts/signup"

      fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
      fill_in("Enter your email address", with: "example@example.com")
      click_button("Create alert")

      expect(page).to have_content("Now check your email")
      expect(page).to have_content("Return to applications near 24 Bruce Rd, Glenbrook")

      confirm_alert_in_email

      expect(page).to have_content("your alert has been activated")
      expect(page).to have_content("24 Bruce Rd, Glenbrook NSW 2773")

      expect(preexisting_alert.reload.created_at).to eq 3.days.ago
      expect(preexisting_alert.reload.updated_at).to eq Time.current
    end
  end

  context "when there is already an confirmed alert for the address" do
    let!(:preexisting_alert) do
      create(:confirmed_alert, address: "24 Bruce Rd, Glenbrook NSW 2773",
                               user: create(:confirmed_user, email: "jenny@email.org"),
                               created_at: 3.days.ago,
                               updated_at: 3.days.ago)
    end

    it "see the confirmation page, so we don't leak information, but also get a notice about the signup attempt" do
      visit "/alerts/signup"

      fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
      fill_in("Enter your email address", with: "jenny@email.org")
      click_button("Create alert")

      expect(page).to have_content("Now check your email")
      expect(page).to have_content("Return to applications near 24 Bruce Rd, Glenbrook")

      open_last_email_for("jenny@email.org")

      expect(current_email.default_part_body.to_s).to have_content(
        "We just received a new request to send PlanningAlerts for 24 Bruce Rd, Glenbrook NSW 2773\nto your email address."
      )
    end

    context "when it is unsubscribed" do
      before do
        preexisting_alert.unsubscribe!
      end

      it "successfully" do
        visit "/alerts/signup"

        fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
        fill_in("Enter your email address", with: "jenny@email.org")
        click_button("Create alert")

        expect(page).to have_content("Now check your email")
        expect(page).to have_content("Return to applications near 24 Bruce Rd, Glenbrook")

        open_email("jenny@email.org")

        click_first_link_in_email

        expect(page).to have_content("your alert has been activated")
        expect(page).to have_content("24 Bruce Rd, Glenbrook NSW 2773")
      end
    end
  end

  # Commenting out because having trouble getting this to work
  # context "with javascript" do
  #   scenario "autocomplete results are displayed", js: true do
  #     visit "/alerts/signup"
  #
  #     fill_in "Enter a street address", with: "24 Bruce Road Glenb"
  #
  #     expect_autocomplete_suggestions_to_include "Bruce Road, Glenbrook NSW"
  #   end
  # end

  def confirm_alert_in_email
    open_email("example@example.com")
    expect(current_email).to have_subject("PlanningAlerts: Please confirm your alert")
    expect(current_email.default_part_body.to_s).to include("24 Bruce Rd, Glenbrook NSW 2773")
    click_first_link_in_email
  end
end
