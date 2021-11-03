# frozen_string_literal: true

require "spec_helper"

describe "Admin confirms comment for user" do
  around do |test|
    Timecop.freeze(Time.zone.local(2016, 10, 10)) { test.run }
  end

  before do
    application = create(:geocoded_application,
                         authority: create(:contactable_authority))
    create(:unconfirmed_comment,
           name: "Alena",
           id: 1,
           created_at: 3.days.ago,
           application: application)
  end

  it "successfully" do
    sign_in_as_admin

    click_link "Comments"

    click_link "Alena"

    expect(page).to have_content "Confirmed\nno"

    click_button "Confirm"

    expect(page).to have_content "Comment confirmed and sent"
    expect(page).to have_content "Confirmed\nyes"
    expect(page).to have_content "Confirmed at Mon, 10 Oct 2016"
    expect(page).not_to have_button "Confirm"
  end
end
