require "spec_helper"
feature "View a reply from a councillor" do
  given(:comment) do
    VCR.use_cassette("planningalerts") do
      authority = create(:authority, full_name: "City of Sydney")
      create(
        :comment_to_councillor,
        :confirmed,
        name: "Richard Pope",
        councillor: create(:councillor, name: "Louise Councillor", authority: authority),
        application: create(:application, authority: authority)
      )
    end
  end

  before do
    create(:reply, comment: comment, councillor: comment.councillor)
  end

  scenario "on the application page" do
    visit application_path(comment.application)

    expect(page).to have_content("Richard Pope wrote to local councillor Louise Councillor")
    expect(page).to have_content("Louise Councillor local councillor for City of Sydney\nreplied to Richard Pope")
  end

  context "when they are not one of the authority's current councillors" do
    before do
      comment.councillor.update(current: false)
    end

    scenario "on the application page" do
      visit application_path(comment.application)

      expect(page).to have_content("Richard Pope wrote to local councillor Louise Councillor")
      expect(page).to have_content("Louise Councillor local councillor for City of Sydney\nreplied to Richard Pope")
    end
  end
end
