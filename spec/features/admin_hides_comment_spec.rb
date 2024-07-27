# frozen_string_literal: true

require "spec_helper"

describe "Admin hides comment" do
  before do
    create(:published_comment, id: 1)
  end

  it "successfully" do
    sign_in_as_admin

    click_on "Comments"

    click_on "Edit"

    check "Hidden"
    click_on "Update Comment"

    expect(page).to have_content("Comment was successfully updated")
    expect(page).to have_content("Hidden\nyes")
  end
end
