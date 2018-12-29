# frozen_string_literal: true

require "spec_helper"
feature "View a message sent to a councillor" do
  given(:comment) do
    create(
      :comment_to_councillor,
      :confirmed,
      name: "Richard Pope",
      councillor: create(:councillor, name: "Louise Councillor")
    )
  end

  scenario "on the application page" do
    visit application_path(comment.application)

    expect(page).to have_content("Richard Pope wrote to local councillor Louise Councillor")
  end

  context "when they are not one of the authority's current councillors" do
    before do
      comment.councillor.update(current: false)
    end

    scenario "on the application page" do
      visit application_path(comment.application)

      expect(page).to have_content("Richard Pope wrote to local councillor Louise Councillor")
    end
  end
end
