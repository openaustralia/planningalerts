# frozen_string_literal: true

require "spec_helper"

feature "Send a message to a councillor" do
  # As someone interested in a local development application,
  # let me write to my local councillor about it,
  # so that I can get their help or feedback
  # and find out where they stand on this development I care about

  context "when writing to councillors is unavailable" do
    given(:authority) { create(:authority, full_name: "Foo", write_to_councillors_enabled: false) }

    background do
      application = create(:geocoded_application, id: "1", authority_id: authority.id, comment_url: "mailto:foo@bar.com")
      visit application_path(application)
    end

    context "and there are no councillors on this authority" do
      scenario "can’t see councillor messages sections" do
        expect(page).to_not have_content("Who should this go to?")
        # TODO: and you should not be able to write and submit a message.
      end
    end

    context "and there are councillors for this authority" do
      background do
        create(:councillor, name: "Louise Councillor", authority: authority)
      end

      scenario "can’t see councillor messages sections" do
        expect(page).to_not have_content("Who should this go to?")
        # TODO: and you should not be able to write and submit a message.
      end
    end
  end

  context "when writing to councillors is available" do
    given(:authority) { create(:contactable_authority, full_name: "Marrickville Council", write_to_councillors_enabled: true) }
    given(:application) { create(:geocoded_application, id: "1", authority: authority) }

    around do |test|
      with_modified_env COUNCILLORS_ENABLED: "true" do
        test.run
      end
    end

    context "and there are no councillors on this authority" do
      scenario "can’t see councillor messages sections" do
        visit application_path(application)

        expect(page).to_not have_content("Who should this go to?")
      end
    end

    context "and there are councillors but not on this authority" do
      background do
        create(:councillor, name: "Louise Councillor", authority: create(:authority))
      end

      scenario "can’t see councillor messages sections" do
        visit application_path(application)

        expect(page).to_not have_content("Who should this go to?")
      end
    end

    context "and there are councillors on this authority" do
      background do
        create(:councillor, name: "Louise Councillor", authority: authority)
        create(:councillor, name: "Fatima Councillor", current: false, authority: authority)
      end

      scenario "sending a message" do
        visit application_path(application)

        expect(page).to have_content("Who should this go to?")

        fill_in("Have your say on this application", with: "I think this is a really good idea")
        fill_in("Your name", with: "Matthew Landauer")

        expect(page).to have_content("Post a comment for the planning authority or one of your elected local councillors")
        expect(page).to have_content("Write to the planning authority (#{application.authority.full_name}) if you want your comment considered when they decide whether to approve this application.")

        within("#comment-receiver-inputgroup") do
          choose "Louise Councillor"
        end

        fill_in("Your email", with: "example@example.com")

        click_button("Post your public comment")

        expect(page).to have_content("Now check your email")
        expect(page).to have_content("Louise Councillor")
        expect(page).to_not have_content("Marrickville Council")

        expect(unread_emails_for("example@example.com").size).to eq 1
        open_email("example@example.com")
        # TODO: Review this text, does it still make sense for these messages?
        expect(current_email).to have_subject("Please confirm your comment")
        expect(current_email).to have_content("to local councillor Louise Councillor")
        expect(current_email).to_not have_content("to Marrickville Council")

        click_first_link_in_email

        expect(page).to have_content "Your comment has been sent to local councillor Louise Councillor and posted below."
        expect(page).to have_content "I think this is a really good idea"
      end

      scenario "only current councillors are available to write to" do
        visit application_path(application)

        expect(page).to_not have_content "Fatima Councillor"
      end

      scenario "getting an error after not selecting who your comment goes to" do
        visit application_path(application)

        expect(page).to have_content("Who should this go to?")

        fill_in("Have your say on this application", with: "I think this is a really good idea")
        fill_in("Your name", with: "Matthew Landauer")

        # TODO: Get javascript driving working so the actual page can be tested
        #       with the councillor list toggler.
        #       This is currently working with the non-js version which
        #       hardly anyone will actually use, though the validation works the same.

        fill_in("Your email", with: "example@example.com")

        click_button("Post your public comment")

        expect(page).to have_content("You need to select who your message should go to from the list below.")
      end
    end
  end

  context "when a message for a councillor is confirmed" do
    given(:councillor) { create(:councillor, name: "Louise Councillor", email: "louise@council.nsw.gov.au") }
    given(:comment) do
      application = create(:geocoded_application, id: 8, address: "24 Bruce Road Glenbrook", description: "A lovely house")
      create(:comment, application: application,
                       name: "Matthew Landauer",
                       councillor: councillor,
                       text: "I think this is a really good idea")
    end

    background :each do
      comment.confirm!
    end

    scenario "coucillor receives the message" do
      expect(unread_emails_for(Comment.last.application.authority.email).size).to eq 0
      expect(unread_emails_for("louise@council.nsw.gov.au").size).to eq 1

      open_email("louise@council.nsw.gov.au")

      expect(current_email).to_not have_content("For the attention of the General Manager / Planning Manager / Planning Department")
      expect(current_email).to have_content("Louise Councillor")
      expect(current_email).to have_content("I think this is a really good idea")
      expect(current_email).to have_content("From Matthew Landauer")
      expect(current_email).to have_body_text('The planning application is for <a href="https://dev.planningalerts.org.au/applications/8?utm_campaign=view-application&utm_medium=email&utm_source=councillor-notifications">24 Bruce Road Glenbrook</a>')
      expect(current_email).to have_content("A lovely house")
    end

    scenario "viewing the comment on the application page" do
      visit application_path(comment.application)

      expect(page).to have_content "Matthew Landauer wrote to local councillor Louise Councillor"
      expect(page).to have_content "Delivered to local councillor Louise Councillor"
    end

    context "twice" do
      background do
        comment.confirm!
      end

      scenario "councillor doesn't get two messages" do
        expect(unread_emails_for("louise@council.nsw.gov.au").size).to eq 1
      end
    end
  end
end
