# frozen_string_literal: true

require "spec_helper"

feature "Admin hides comment" do
  background do
    VCR.use_cassette("planningalerts") do
      create(:confirmed_comment, id: 1)
    end
  end

  scenario "successfully" do
    sign_in_as_admin

    click_link "Comments"

    within("#comment_1") do
      click_link "Edit"
    end

    check "Hidden"
    click_button "Update Comment"

    expect(page).to have_content("Comment was successfully updated")
    expect(page).to have_content("Hidden Yes")
  end

  scenario "successfully when writing to councillor feature is enabled" do
    with_modified_env COUNCILLORS_ENABLED: "true" do
      sign_in_as_admin

      click_link "Comments"

      within("#comment_1") do
        click_link "Edit"
      end

      check "Hidden"
      click_button "Update Comment"

      expect(page).to have_content("Comment was successfully updated")
      expect(page).to have_content("Hidden Yes")
    end
  end
end
