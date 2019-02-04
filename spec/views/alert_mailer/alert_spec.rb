# frozen_string_literal: true

require "spec_helper"

# HTML email
describe "alert_mailer/alert.html.haml" do
  let(:application) do
    create(:geocoded_application,
           description: "Alterations & additions",
           address: "24 Bruce Road Glenbrook")
  end

  before(:each) do
    assign(:applications, [application])
    assign(:comments, [])
    assign(:replies, [])
    assign(:host, "foo.com")
  end

  it "should not use html entities to encode the description" do
    assign(:alert, create(:alert))
    render
    expect(rendered).to have_content("Alterations & additions")
  end

  context "when there is a comment to an authority" do
    before do
      comment = create(:comment_to_authority,
                       name: "Matthew Landauer",
                       application: application)

      assign(:comments, [comment])
      assign(:alert, create(:alert))

      render
    end

    it { expect(rendered).to have_content("Matthew Landauer\ncommented") }
    it { expect(rendered).to have_content("On\n“Alterations & additions” at 24 Bruce Road Glenbrook") }
  end

  context "when there is a comment to a councillor" do
    let(:comment) do
      create(:comment_to_councillor, name: "Matthew Landauer")
    end

    before :each do
      assign(:comments, [comment])
      assign(:alert, create(:alert))
    end

    it "includes the comment" do
      render

      expect(rendered).to have_content("Matthew Landauer\nwrote to\n\nlocal councillor\nLouise Councillor")
    end

    context "and it has not be replied to" do
      before :each do
        render
      end

      it { expect(rendered).to have_content("Delivered to local councillor Louise Councillor") }
      it { expect(rendered).to have_content("They are yet to respond") }
    end

    context "and it has be replied to" do
      let(:reply) { create(:reply, comment: comment, councillor: comment.councillor) }

      before :each do
        assign(:replies, [reply])

        render
      end

      it { expect(rendered).to_not have_content("They are yet to respond") }
    end
  end

  context "when there is a reply from a councillor" do
    before do
      comment = VCR.use_cassette("planningalerts") do
        create(:comment_to_councillor, name: "Matthew Landauer")
      end
      multi_line_reply_text = "Thanks for your comment\n\nBest wishes,\nLouise"
      reply = create(
        :reply,
        text: multi_line_reply_text,
        comment: comment,
        councillor: comment.councillor
      )
      assign(:replies, [reply])
      assign(:alert, create(:alert))

      render
    end

    it { expect(rendered).to have_content "Local councillor Louise Councillor\nreplied to\n\nMatthew Landauer" }

    it "renders linebreak formatting into html" do
      expect(rendered).to include(
        "<p>Thanks for your comment</p>\n\n<p>Best wishes,\n<br>Louise</p>"
      )
    end
  end
end

# Text only email
describe "alert_mailer/alert.text.erb" do
  let(:application) do
    create(:geocoded_application,
           description: "Alterations & additions",
           address: "24 Bruce Road Glenbrook")
  end

  before(:each) do
    assign(:applications, [application])
    assign(:comments, [])
    assign(:replies, [])
    assign(:host, "foo.com")
  end

  context "when there is a comment to an authority" do
    before do
      comment = create(:comment_to_authority,
                       name: "Matthew Landauer",
                       application: application)

      assign(:comments, [comment])
      assign(:alert, create(:alert))

      render
    end

    it { expect(rendered).to have_content("Matthew Landauer commented") }
    it { expect(rendered).to have_content("on “Alterations & additions” at 24 Bruce Road Glenbrook") }
  end

  context "when there is a comment to a councillor" do
    before do
      comment = VCR.use_cassette("planningalerts") do
        create(:comment_to_councillor, name: "Matthew Landauer")
      end
      assign(:comments, [comment])
      assign(:alert, create(:alert))

      render
    end

    it { expect(rendered).to have_content("Matthew Landauer wrote to local councillor Louise Councillor") }
  end

  context "when there is a reply from a councillor" do
    before do
      comment = VCR.use_cassette("planningalerts") do
        create(:comment_to_councillor, name: "Matthew Landauer")
      end
      reply = create(:reply, comment: comment, councillor: comment.councillor)
      assign(:replies, [reply])
      assign(:alert, create(:alert))

      render
    end

    it { expect(rendered).to have_content "Local councillor Louise Councillor replied to Matthew Landauer" }
  end
end
