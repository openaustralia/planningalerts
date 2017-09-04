require 'spec_helper'

describe AdminNoticeMailer do
  before :each do
    @authority = build(:authority, full_name: "Casey City Council")
    @councillor_contribution = create(:councillor_contribution, authority: @authority)
    @mailer = AdminNoticeMailer.notice_for_councillor_contribution(@councillor_contribution)
  end
  it "should come from the moderator's email address" do
    expect(@mailer.from).to eq(["moderator@planningalerts.org.au"])
  end

  it "should go to the moderator email address" do
    expect(@mailer.to).to eq(["moderator@planningalerts.org.au"])
  end

  it "should tell the moderator what the email is about" do
    expect(@mailer.subject).to eq("New councillor contribution")
  end

  it "should contain the authority name of the councillor contribution" do
    expect(@mailer.body.to_s).to include("Casey City Council")
  end

  it "should contain the link to the admin show page of the councillor contribition" do
  end
end
