require 'spec_helper'

feature "Send a message to a councillor" do
  # As someone interested in a local development application,
  # let me write to my local councillor about it,
  # so that I can get their help or feedback
  # and find out where they stand on this development I care about

  context "when with_councillor param is not true" do
    background do
      authority = create(:authority, full_name: "Foo")
      VCR.use_cassette('planningalerts') do
        application = create(:application, id: "1", authority_id: authority.id, comment_url: 'mailto:foo@bar.com')
        visit application_path(application)
      end
    end

    scenario "can’t see councillor messages sections" do
      expect(page).to_not have_content("Who should this go to?")
      # TODO: and you should not be able to write and submit a message.
    end
  end

  context "when with_councillors param equals 'true'" do
    given(:application) { VCR.use_cassette('planningalerts') { create(:application, id: "1", comment_url: 'mailto:foo@bar.com') } }

    scenario "sending a message" do
      visit application_path(application, with_councillors: "true")

      expect(page).to have_content("Who should this go to?")

      fill_in("Have your say on this application", with: "I think this is a really good idea")
      fill_in("Your name", with: "Matthew Landauer")

      expect(page).to have_content("Write to the council if you want your comment considered when they decide whether to approve this application.")

      within("#comment-receiver-inputgroup") do
        choose "councillor-2"
      end

      fill_in("Your email", with: "example@example.com")
      fill_in("Your street address", with: "11 Foo Street")

      click_button("Post your public comment")

      # While this is still a prototype prevent a comment from being created
      expect(page).to_not have_content("Now check your email")
      expect(page).to have_content("Your comment has not been sent")
      expect(page).to_not have_content("I think this is a really good idea")

      # TODO: the message appears on the page
      # TODO: the message is sent off to the councillor
    end
  end
end
