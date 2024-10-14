# frozen_string_literal: true

require "spec_helper"

describe "Sign up for alerts" do
  include Devise::Test::IntegrationHelpers

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
    allow(GoogleGeocodeService).to receive(:call).with(address: "24 Bruce Rd, Glenbrook", key: nil).and_return(GeocoderResults.new([g], nil))
    allow(GoogleGeocodeService).to receive(:call).with(address: "24 Bruce Rd, Glenbrook NSW 2773", key: nil).and_return(GeocoderResults.new([g], nil))
    allow(GoogleGeocodeService).to receive(:call).with(address: "Bruce Rd", key: nil).and_return(
      GeocoderResults.new([], "Please enter a full street address, including suburb and state, e.g. Bruce Rd, Victoria")
    )
  end

  it "successfully" do
    user = create(:confirmed_user)
    sign_in user
    visit "/alerts/signup"

    fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
    click_on("Create alert")

    expect(page).to have_content("You succesfully added a new alert for 24 Bruce Rd, Glenbrook NSW 2773")
    expect(
      Alert.active.find_by(address: "24 Bruce Rd, Glenbrook NSW 2773",
                           radius_meters: "2000",
                           user:)
    ).not_to be_nil
  end

  it "unsuccessfully with an invalid address" do
    sign_in create(:confirmed_user)
    visit "/alerts/signup"

    fill_in("Enter a street address", with: "Bruce Rd")
    click_on("Create alert")

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
      sign_in create(:confirmed_user)
      visit application_path(application)

      click_on("Save")

      expect(page).to have_content("You succesfully added a new alert for 24 Bruce Rd, Glenbrook NSW 2773")
    end
  end

  context "when via the homepage" do
    before do
      create(:geocoded_application,
             address: "26 Bruce Rd, Glenbrook NSW 2773",
             lat: -33.772812, lng: 150.624252, lonlat: RGeo::Geographic.spherical_factory(srid: 4326).point(150.624252, -33.772812))
    end

    it "successfully" do
      sign_in create(:confirmed_user)
      visit root_path
      fill_in("Street address", with: "24 Bruce Rd, Glenbrook")
      within("form") do
        click_on("Search")
      end

      click_on("Save", match: :first)

      expect(page).to have_content("You succesfully added a new alert for 24 Bruce Rd, Glenbrook NSW 2773")
    end
  end

  it "when via the homepage with a pre-existing user but not logged in" do
    create(:geocoded_application, address: "26 Bruce Rd, Glenbrook NSW 2773", lat: -33.772812, lng: 150.624252, lonlat: RGeo::Geographic.spherical_factory(srid: 4326).point(150.624252, -33.772812))
    user = create(:confirmed_user, email: "example@example.com", password: "mypassword")
    sign_in user
    visit root_path
    sign_out user

    visit root_path
    fill_in("Street address", with: "24 Bruce Rd, Glenbrook")
    within("form") do
      click_on("Search")
    end

    expect(page).to have_content("Search results")
    expect(page).to have_content("Create an account or sign in")
    click_on("sign in", match: :first)

    fill_in("Your email", with: "example@example.com")
    fill_in("Password", with: "mypassword")
    click_on("Sign in")

    expect(page).to have_content("Signed in successfully.")
    # We should be back at the same page from where we clicked "sign in"
    expect(page).to have_content("Search results")
    click_on("Save", match: :first)

    expect(page).to have_content("You succesfully added a new alert for 24 Bruce Rd, Glenbrook NSW 2773")
  end

  it "when via the homepage with a pre-existing user but not logged in in the alternate flow" do
    use_ab_test logged_out_alert_flow_order: "create_alert_sign_in"

    create(:geocoded_application, address: "26 Bruce Rd, Glenbrook NSW 2773", lat: -33.772812, lng: 150.624252, lonlat: RGeo::Geographic.spherical_factory(srid: 4326).point(150.624252, -33.772812))
    user = create(:confirmed_user, email: "example@example.com", password: "mypassword")
    sign_in user
    visit root_path
    sign_out user

    visit root_path
    fill_in("Street address", with: "24 Bruce Rd, Glenbrook")
    within("form") do
      click_on("Search")
    end

    expect(page).to have_content("Search results")
    expect(page).to have_content("Save this search as an email alert")
    click_on("Save", match: :first)

    expect(page).to have_content("You'll receive email alerts when new applications match this search")
    click_on("Sign in")

    expect(page).to have_content("Sign in to save this search")
    expect(page).to have_content("Applications within 2 km of 24 Bruce Rd, Glenbrook")

    fill_in("Your email", with: "example@example.com")
    fill_in("Password", with: "mypassword")
    click_on("Sign in")

    expect(page).to have_content("You succesfully signed in and added a new alert for 24 Bruce Rd, Glenbrook NSW 2773")
  end

  it "when via the homepage not logged in and doesn't know the password in the alternate flow" do
    use_ab_test logged_out_alert_flow_order: "create_alert_sign_in"

    create(:geocoded_application, address: "26 Bruce Rd, Glenbrook NSW 2773", lat: -33.772812, lng: 150.624252, lonlat: RGeo::Geographic.spherical_factory(srid: 4326).point(150.624252, -33.772812))
    user = create(:confirmed_user, email: "example@example.com", password: "mypassword")
    sign_in user
    visit root_path
    sign_out user

    visit root_path
    fill_in("Street address", with: "24 Bruce Rd, Glenbrook")
    within("form") do
      click_on("Search")
    end

    expect(page).to have_content("Search results")
    expect(page).to have_content("Save this search as an email alert")
    click_on("Save", match: :first)

    expect(page).to have_content("You'll receive email alerts when new applications match this search")
    click_on("Sign in")

    expect(page).to have_content("Sign in to save this search")
    expect(page).to have_content("Applications within 2 km of 24 Bruce Rd, Glenbrook")

    fill_in("Your email", with: "example@example.com")
    fill_in("Password", with: "thispasswordiswrong")
    click_on("Sign in")

    expect(page).to have_content("Invalid Email or password")

    fill_in("Password", with: "mypassword")
    click_on("Sign in")

    expect(page).to have_content("You succesfully signed in and added a new alert for 24 Bruce Rd, Glenbrook NSW 2773")
  end

  it "when via the homepage not logged in and already has an alert in the alternate flow" do
    use_ab_test logged_out_alert_flow_order: "create_alert_sign_in"

    create(:geocoded_application, address: "26 Bruce Rd, Glenbrook NSW 2773", lat: -33.772812, lng: 150.624252, lonlat: RGeo::Geographic.spherical_factory(srid: 4326).point(150.624252, -33.772812))
    user = create(:confirmed_user, email: "example@example.com", password: "mypassword")
    sign_in user
    visit root_path
    sign_out user

    create(:alert, user:, address: "24 Bruce Rd, Glenbrook NSW 2773")

    visit root_path
    fill_in("Street address", with: "24 Bruce Rd, Glenbrook")
    within("form") do
      click_on("Search")
    end

    expect(page).to have_content("Search results")
    expect(page).to have_content("Save this search as an email alert")
    click_on("Save", match: :first)

    expect(page).to have_content("You'll receive email alerts when new applications match this search")
    click_on("Sign in")

    expect(page).to have_content("Sign in to save this search")
    expect(page).to have_content("Applications within 2 km of 24 Bruce Rd, Glenbrook")

    fill_in("Your email", with: "example@example.com")
    fill_in("Password", with: "mypassword")
    click_on("Sign in")

    expect(page).to have_content("You already have an alert for that address")
  end

  it "when via the homepage not registered in the alternate flow" do
    use_ab_test logged_out_alert_flow_order: "create_alert_sign_in"

    create(:geocoded_application, address: "26 Bruce Rd, Glenbrook NSW 2773", lat: -33.772812, lng: 150.624252, lonlat: RGeo::Geographic.spherical_factory(srid: 4326).point(150.624252, -33.772812))

    visit root_path
    fill_in("Street address", with: "24 Bruce Rd, Glenbrook")
    within("form") do
      click_on("Search")
    end

    expect(page).to have_content("Search results")
    expect(page).to have_content("Save this search as an email alert")
    click_on("Save", match: :first)

    expect(page).to have_content("You'll receive email alerts when new applications match this search")
    click_on("Create an account")

    expect(page).to have_content("Create an account to save this search")
    expect(page).to have_content("Applications within 2 km of 24 Bruce Rd, Glenbrook")

    fill_in("Email", with: "example@example.com")
    fill_in("Create a password", with: "mypassword")
    click_on("Create account and save")

    expect(page).to have_content("Now check your email")

    open_email("example@example.com")
    expect(current_email).to have_subject("PlanningAlerts: Confirmation instructions")
    expect(current_email.default_part_body.to_s).to include("Thanks for getting onboard!")

    click_email_link_matching(/confirmation/)

    expect(page).to have_content("Your email address has been successfully confirmed")
    expect(page).to have_content("you are now logged in")
    expect(page).to have_content("you added a new alert for 24 Bruce Rd, Glenbrook")
  end

  it "when via the homepage not registered in the alternate flow but email already used" do
    use_ab_test logged_out_alert_flow_order: "create_alert_sign_in"

    create(:geocoded_application, address: "26 Bruce Rd, Glenbrook NSW 2773", lat: -33.772812, lng: 150.624252, lonlat: RGeo::Geographic.spherical_factory(srid: 4326).point(150.624252, -33.772812))
    user = create(:confirmed_user, email: "example@example.com", password: "mypassword")
    sign_in user
    visit root_path
    sign_out user

    visit root_path
    fill_in("Street address", with: "24 Bruce Rd, Glenbrook")
    within("form") do
      click_on("Search")
    end

    expect(page).to have_content("Search results")
    expect(page).to have_content("Save this search as an email alert")
    click_on("Save", match: :first)

    expect(page).to have_content("You'll receive email alerts when new applications match this search")
    click_on("Create an account")

    expect(page).to have_content("Create an account to save this search")
    expect(page).to have_content("Applications within 2 km of 24 Bruce Rd, Glenbrook")

    fill_in("Email", with: "example@example.com")
    fill_in("Create a password", with: "mypassword")
    click_on("Create account and save")

    expect(page).to have_content("You already have an account with that email address")
    fill_in("Email", with: "example2@example.com")
    fill_in("Create a password", with: "mypassword")
    click_on("Create account and save")

    open_email("example2@example.com")
    expect(current_email).to have_subject("PlanningAlerts: Confirmation instructions")
    expect(current_email.default_part_body.to_s).to include("Thanks for getting onboard!")

    click_email_link_matching(/confirmation/)

    expect(page).to have_content("Your email address has been successfully confirmed")
    expect(page).to have_content("you are now logged in")
    expect(page).to have_content("you added a new alert for 24 Bruce Rd, Glenbrook")
  end

  it "when via the homepage but not yet have an account" do
    create(:geocoded_application, address: "26 Bruce Rd, Glenbrook NSW 2773", lat: -33.772812, lng: 150.624252, lonlat: RGeo::Geographic.spherical_factory(srid: 4326).point(150.624252, -33.772812))

    visit root_path
    fill_in("Street address", with: "24 Bruce Rd, Glenbrook")
    within("form") do
      click_on("Search")
    end

    expect(page).to have_content("Search results")
    expect(page).to have_content("Create an account or sign in")
    click_on("Create an account", match: :first)

    fill_in("Your full name", with: "Ms Example")
    fill_in("Email", with: "example@example.com")
    fill_in("Create a password", with: "mypassword")
    click_on("Create my account")

    expect(page).to have_content("You will shortly receive an email from PlanningAlerts.org.au")

    open_email("example@example.com")
    expect(current_email).to have_subject("PlanningAlerts: Confirmation instructions")

    # Do these shenanigans to get the first link in this case
    link = links_in_email(current_email).find { |u| u =~ %r{https://dev\.planningalerts\.org\.au} }
    visit request_uri(link)

    expect(page).to have_content("Your email address has been successfully confirmed and you are now logged in.")
    expect(page).to have_content("Ms Example")

    # We should be back at the same page from where we clicked "sign in"
    expect(page).to have_content("Search results")
    click_on("Save", match: :first)

    expect(page).to have_content("You succesfully added a new alert for 24 Bruce Rd, Glenbrook NSW 2773")
  end

  context "when there is already an alert for the address" do
    let(:user) { create(:confirmed_user, email: "jenny@email.org") }
    let!(:preexisting_alert) do
      create(:alert, address: "24 Bruce Rd, Glenbrook NSW 2773",
                     user:,
                     created_at: 3.days.ago,
                     updated_at: 3.days.ago)
    end

    it "see the confirmation page, so we don't leak information, but also get a notice about the signup attempt" do
      sign_in user
      visit "/alerts/signup"

      fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
      click_on("Create alert")

      expect(page).to have_content("You already have an alert for that address")
    end

    context "when it is unsubscribed" do
      before do
        preexisting_alert.unsubscribe!
      end

      it "successfully" do
        sign_in user
        visit "/alerts/signup"

        fill_in("Enter a street address", with: "24 Bruce Rd, Glenbrook")
        click_on("Create alert")

        expect(page).to have_content("You succesfully added a new alert for 24 Bruce Rd, Glenbrook NSW 2773")
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
