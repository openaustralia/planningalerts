# frozen_string_literal: true

require "spec_helper"

feature "Admin edits comment" do
  background do
    VCR.use_cassette("planningalerts") do
      create(:confirmed_comment,
             name: "Alena",
             id: 1,
             confirmed_at: 3.days.ago)
    end
  end

  scenario "successfully" do
    sign_in_as_admin

    click_link "Comments"

    within("#comment_1") do
      click_link "Edit"
    end

    fill_in "Name", with: "Foo"
    click_button "Update Comment"

    expect(page).to have_content("Comment was successfully updated")

    visit application_path(Comment.find(1).application)

    expect(page).to have_content "Foo commented 3 days ago"
  end
end
