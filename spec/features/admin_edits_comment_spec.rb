# frozen_string_literal: true

require "spec_helper"

describe "Admin edits comment" do
  before do
    create(:published_comment,
           published: true,
           name: "Alena",
           id: 1,
           published_at: 3.days.ago)
  end

  it "successfully" do
    sign_in_as_admin

    click_on "Comments"

    click_on "Edit"

    fill_in "Name", with: "Foo"
    click_on "Update Comment"

    expect(page).to have_content("Comment was successfully updated")

    visit application_path(Comment.find(1).application)

    expect(page).to have_content "Foo"
    expect(page).to have_content "3 days ago"
  end
end
