require 'spec_helper'

describe "councillor_contributions/_instructions_body" do
  context "when the authority has a website url" do
    before do
      assign(
        :authority,
        create(:authority, full_name: "Example Council", website_url: "https://example.nsw.gov.au")
      )
    end

    it "render a link to the website" do
      render "instructions_body"

      expect(rendered).to include "<a title=\"Go to the Example Council website.\" href=\"https://example.nsw.gov.au\">Example Council</a>"
    end
  end

  context "when the authority does not have a website url" do
    before do
      assign(
        :authority,
        create(:authority, full_name: "Example Council", website_url: nil)
      )
    end

    it "render it's name with no link" do
      render "instructions_body"

      expect(rendered).to_not include "<a href=\"https://example.nsw.gov.au\" title=\"Go to the Example Council website.\">Example Council</a>"
      expect(rendered).to include "Example Council"
    end
  end
end
