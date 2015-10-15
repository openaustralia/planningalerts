require 'spec_helper'

describe CommentsHelper do
  describe "#donation_declaration_notice" do
    it { expect(helper.donation_declaration_notice).to eq "If you have made a donation to a Councillor and/or gift to a Councillor or Council employee you may #{link_to("need to disclose this", faq_path(:anchor => "disclosure"))}." }
    it { expect(helper.donation_declaration_notice).to be_html_safe }
  end
end
