# frozen_string_literal: true

require "spec_helper"

describe ReportMailer do
  before :each do
    @comment = build(:comment,
                     application: build(:application, id: 2),
                     text: "I'm saying something abusive",
                     name: "Jack Rude",
                     email: "rude@foo.com",
                     id: "23")

    @report = build(:report,
                    name: "Joe Reporter",
                    email: "reporter@foo.com",
                    comment: @comment,
                    details: "It's very rude!")
    @notifier = ReportMailer.notify(@report)
  end

  it "should come from the moderator's email address" do
    expect(@notifier.from).to eq(["moderator@planningalerts.org.au"])
  end

  it "should have a replyto of the reporter's email address" do
    expect(@notifier.reply_to).to eq(["reporter@foo.com"])
  end

  it "should go to the moderator email address" do
    expect(@notifier.to).to eq(["moderator@planningalerts.org.au"])
  end

  it "should tell the moderator what the email is about" do
    expect(@notifier.subject).to eq("PlanningAlerts: Abuse report")
  end

  it "should tell the moderator everything they need to know to decide on what to do with the report" do
    expect(@notifier.body.to_s).to eq <<~REPORT
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
    expect(@notifier.body.to_s).to_not have_content("rude@foo.com")
  end
end
