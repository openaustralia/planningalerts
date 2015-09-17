require 'spec_helper'

feature "Send a message to a councilor" do
  # As someone interested in a local development application,
  # let me write to my local councillor about it,
  # so that I can get their help or feedback
  # and find out where they stand on this development I care about

  context "when not logged in" do
    background do
      authority = create(:authority, full_name: "Foo")
      VCR.use_cassette('planningalerts') do
        application = create(:application, id: "1", authority_id: authority.id, comment_url: 'mailto:foo@bar.com')
        visit application_path(application)
      end
    end

    scenario "can’t see councilor messages sections" do
      # there should not be an introduction to writing to your councillors
      # and you should not be able to write and submit a message.
    end
  end

  context "when logged in as admin" do
    background do
      authority = create(:authority, full_name: "Foo")
      admin = create(:admin)

      visit new_user_session_path
      within("#new_user") do
        fill_in "Email", with: admin.email
        fill_in "Password", with: admin.password
      end
      click_button "Sign in"
      expect(page).to have_content "Signed in successfully"

      VCR.use_cassette('planningalerts') do
        application = create(:application, id: "1", authority_id: authority.id, comment_url: 'mailto:foo@bar.com')
        visit application_path(application)
      end
    end

    scenario "sending a message" do
      # there should be a short text introduction to writing to your councillors
      # there should be an expanation that this wont necessarily impact the decision about this application,
      #   encourage people to use the official process for that.
      # there should be a list of councilors to select from
      # select the councillor you would like to write to
      # fill out your name
      # write your message
      # post your message
      # the message appears on the page
      # the message is sent off to the councillor
    end
  end
end
