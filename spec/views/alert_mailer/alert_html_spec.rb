# frozen_string_literal: true

require "spec_helper"

# HTML email
describe "alert_mailer/alert" do
  let(:application) do
    create(:geocoded_application,
           description: "Alterations & additions",
           address: "24 Bruce Road Glenbrook")
  end

  before do
    assign(:applications, [application])
    assign(:comments, [])
    assign(:host, "foo.com")
    # Jumping through these silly hoops to populate the email attachments with something
    # so the view template is happy
    attachment = instance_double(Mail::Part, url: "foo")
    attachments = {}
    attachments["pencil.png"] = attachment
    attachments["trash.png"] = attachment
    attachments["footer-illustration.png"] = attachment
    allow(view).to receive(:attachments).and_return(attachments)
  end

  it "does not use html entities to encode the description" do
    assign(:alert, create(:alert))
    render
    expect(rendered).to have_content("Alterations & additions")
  end

  context "when there is a comment to an authority" do
    before do
      comment = create(:comment,
                       name: "Matthew Landauer",
                       application:)

      assign(:comments, [comment])
      assign(:alert, create(:alert))

      render
    end

    it { expect(rendered).to have_content("Matthew Landauer commented:") }
    it { expect(rendered).to have_content("24 Bruce Road Glenbrook") }
    it { expect(rendered).to have_content("Alterations & additions") }
  end
end
