# frozen_string_literal: true

require "spec_helper"

describe SupportMailer do
  let(:comment) do
    build(:comment,
          application: create(:geocoded_application, id: 2),
          text: "I'm saying something abusive",
          name: "Jack Rude",
          user: create(:user, email: "rude@foo.com"),
          id: "23")
  end

  let(:report) do
    build(:report,
          name: "Joe Reporter",
          email: "reporter@foo.com",
          comment:,
          details: "It's very rude!")
  end

  let(:notifier) { described_class.report(report) }

  it "comes from the moderator's email address" do
    expect(notifier.from).to eq(["contact@planningalerts.org.au"])
  end

  it "has a replyto of the reporter's email address" do
    expect(notifier.reply_to).to eq(["reporter@foo.com"])
  end

  it "goes to the moderator email address" do
    expect(notifier.to).to eq(["contact@planningalerts.org.au"])
  end

  it "tells the moderator what the email is about" do
    expect(notifier.subject).to eq("PlanningAlerts: Abuse report")
  end

  it "tells the moderator everything they need to know to decide on what to do with the report" do
    expect(notifier.text_part.body.to_s).to eq <<~REPORT
      The abuse report was completed by Joe Reporter (reporter@foo.com) who said:
      It's very rude!

      The original comment was written by Jack Rude who said:
      I'm saying something abusive

      The original comment can be found at:
      https://dev.planningalerts.org.au/applications/2#comment23

      To edit/hide/delete this comment:
      https://dev.planningalerts.org.au/admin/comments/23/edit
    REPORT
  end

  it "doesn’t include the commenters email as this could lead to data leak" do
    expect(notifier.text_part.body.to_s).to have_no_content("rude@foo.com")
  end

  # Contact details are formatted like comments. This tests that a sanitiser
  # change in a Rails upgrade doesn't alter them.
  describe "#contact_message with a link, paragraphs and markup" do
    let(:contact_message) { create(:contact_message, details: CommentExamples::WITH_MARKUP) }

    it "keeps the link, paragraphs and safe formatting, and drops the rest" do
      email = described_class.contact_message(contact_message)
      expect(CommentExamples.rendered(email.body.to_s)).to eq <<~HTML.chomp
        <p>See the plans at <a href="https://example.org/plans" rel="nofollow">https://example.org/plans</a> &amp; the <b>council's</b> report.
        <br>It's a second line.</p>

        <p>A new paragraph alert(1)</p> with a div  and 5 &lt; 6.<p></p>
      HTML
    end
  end
end
