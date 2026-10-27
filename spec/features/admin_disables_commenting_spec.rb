# frozen_string_literal: true

require "spec_helper"

describe "Admin disables commenting for a person" do
  let!(:person) { create(:confirmed_user, name: "Jane Ng", email: "jane@example.org") }

  it "sets and clears the flag from the user page" do
    sign_in_as_admin

    visit edit_admin_user_path(person)

    check "Comments disabled"
    fill_in "Comments disabled reason", with: "Impersonating another person"
    click_on "Update User"

    expect(page).to have_content("User was successfully updated")
    expect(page).to have_content("Comments disabled\nyes")
    expect(page).to have_content("Impersonating another person")

    visit edit_admin_user_path(person)

    uncheck "Comments disabled"
    click_on "Update User"

    expect(page).to have_content("Comments disabled\nno")
  end
end
