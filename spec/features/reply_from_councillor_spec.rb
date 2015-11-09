require "spec_helper"

feature "Councillor replies to a message sent to them" do
  given (:councillor) { create(:councillor, name: "Louise Councillor", email: "louise@council.nsw.gov.au") }
  given (:comment) do
    VCR.use_cassette('planningalerts') do
      application = create(:application, id: 8, address: "24 Bruce Road Glenbrook", description: "A lovely house")
      create(:comment, application: application,
                                 name: "Matthew Landauer",
                                 councillor: councillor,
                                 text: "I think this is a really good idea")
    end
  end

  background { comment.confirm! }

  scenario "reply to a message and it's displayed on the application page" do
    open_email("louise@council.nsw.gov.au")
    expect(current_email).to have_reply_to "replies@planningalerts.org.au"
    # The councillor replies to the message
    # It's sent to replies@planningalerts.org.au
    # An admin checks this mailbox

    # Action: An admin enters the reply in the admin backend

    # Result: It's shown on the application page
  end
end
