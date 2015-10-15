require 'spec_helper'

describe CommentsHelper do
  describe "#donation_declaration_notice" do
    it { expect(helper.donation_declaration_notice).to eq "If you have made a donation to a Councillor and/or gift to a Councillor or Council employee you may #{link_to("need to disclose this", faq_path(:anchor => "disclosure"))}." }
    it { expect(helper.donation_declaration_notice).to be_html_safe }
  end

  describe "#address_input_explanation" do
    it { expect(helper.address_input_explanation).to eq "We never display your street address. #{link_to("Why do you need my address?", faq_path(anchor: "address"))}" }
    it { expect(helper.address_input_explanation).to be_html_safe }
  end
end
