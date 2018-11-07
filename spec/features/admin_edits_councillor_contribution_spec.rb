# frozen_string_literal: true

require "spec_helper"

feature "Admin edits councillor contribution" do
  before do
    create(
      :suggested_councillor,
      id: 1,
      name: "Mila Gilic",
      councillor_contribution: create(:councillor_contribution, id: 1)
    )
  end

  it "successfully" do
    sign_in_as_admin

    click_link "Councillor Contributions"

    within "#councillor_contribution_1" do
      click_link "View"
    end

    within "#suggested_councillor_1" do
      click_link "Edit"
    end

    fill_in "Name", with: "Mila Foo Gilic"

    click_button "Update"

    expect(page).to have_content "Mila Foo Gilic"
  end
end
