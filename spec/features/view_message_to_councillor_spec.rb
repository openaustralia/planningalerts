require 'spec_helper'
feature "View a message sent to a councillor" do
  # TODO: Remove this when we remove the prototype
  context "when with_councillor_message param is not true" do
    given(:application) { VCR.use_cassette('planningalerts') { create(:application, id: "1", comment_url: 'mailto:foo@bar.com') } }

    scenario "can’t see messages to councillors" do
      visit application_path(application)

      expect(page).to_not have_content("wrote to local councillor")
    end
  end

  # TODO: Remove this when we remove the prototype
  context "when with_councillor_message param is true" do
    given(:application) { VCR.use_cassette('planningalerts') { create(:application, id: "1", comment_url: 'mailto:foo@bar.com') } }

    scenario "can see messages to councillors" do
      visit application_path(application, with_councillor_message: "true")

      expect(page).to have_content("wrote to local councillor")
    end
  end

  given(:comment) do
    VCR.use_cassette('planningalerts') do
      create(
        :comment_to_councillor,
        :confirmed,
        name: "Richard Pope",
        councillor: create(:councillor, name: "Louise Councillor")
      )
    end
  end

  scenario "on the application page" do
    visit application_path(comment.application)

    expect(page).to have_content("Richard Pope wrote to local councillor Louise Councillor")
  end
end
