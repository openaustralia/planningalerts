# frozen_string_literal: true

require "spec_helper"

feature "Admin confirms comment for user" do
  around do |test|
    Timecop.freeze(Time.zone.local(2016, 10, 10)) { test.run }
  end

  background do
    application = create(:geocoded_application,
                         authority: create(:contactable_authority))
    create(:unconfirmed_comment,
           name: "Alena",
           id: 1,
           created_at: 3.days.ago,
           application: application)
  end

  scenario "successfully" do
    sign_in_as_admin

    click_link "Comments"
    click_link "All"

    within "#comment_1" do
      click_link "View"
    end

    expect(page).to have_content "unconfirmed"

    click_button "Confirm"

    expect(page).to have_content "Comment confirmed and sent"
    expect(page).to have_content "Confirmed Yes"
    expect(page).to have_content "Confirmed At October 10, 2016"
    expect(page).to_not have_button "Confirm"
  end
end
