require 'spec_helper'

describe AdminNoticeMailer do
  before :each do
    @authority = build(:authority, full_name: "Casey City Council")
    @councillor_contribution = build(:councillor_contribution, authority: @authority)
    @mailer = AdminNoticeMailer.notice_for_councillor_contribution(@councillor_contribution)
  end
  it "should come from the moderator's email address" do
  end

  it "should go to the moderator email address" do
  end

  it "should contain the authority name of the councillor contribution" do
  end

  it "should contain the link to the admin show page of the councillor contribition" do
  end
end
