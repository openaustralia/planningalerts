# frozen_string_literal: true

require "spec_helper"

describe "Admin edits comment" do
  before do
    create(:confirmed_comment,
           name: "Alena",
           id: 1,
           confirmed_at: 3.days.ago)
  end

  it "successfully" do
    sign_in_as_admin

    click_link "Comments"

    click_link "Edit"

    fill_in "Name", with: "Foo"
    click_button "Update Comment"

    expect(page).to have_content("Comment was successfully updated")

    visit application_path(Comment.find(1).application)

    expect(page).to have_content "Foo commented 3 days ago"
  end
end
