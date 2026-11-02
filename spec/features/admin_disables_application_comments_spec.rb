# frozen_string_literal: true

require "spec_helper"

describe "Admin disables comments on an application" do
  let!(:application) { create(:geocoded_application, council_reference: "DA/2026/1") }

  it "reaches the admin page from the application's public page, before any comments exist" do
    sign_in_as_admin

    visit application_path(application)
    click_on "Admin", exact: true

    expect(page).to have_current_path(admin_application_path(application))
  end

  it "doesn't show the admin link to other people" do
    visit application_path(application)

    expect(page).to have_no_link("Admin", href: admin_application_path(application))
  end

  it "turns comments off with a staff-only reason, and back on" do
    sign_in_as_admin

    visit edit_admin_application_path(application)

    check "Comments disabled"
    fill_in "Comments disabled reason", with: "Heated dispute between neighbours"
    click_on "Update Application"

    expect(page).to have_content("Application was successfully updated")
    expect(page).to have_content("Comments disabled\nyes")
    expect(page).to have_content("Heated dispute between neighbours")

    visit edit_admin_application_path(application)

    uncheck "Comments disabled"
    click_on "Update Application"

    expect(page).to have_content("Comments disabled\nno")
  end
end
