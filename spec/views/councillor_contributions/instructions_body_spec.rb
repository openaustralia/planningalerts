require 'spec_helper'

describe "councillor_contributions/_instructions_body" do
  context "when the authority has a website url" do
    it "render a link to the website" do
      assign(
        :authority,
        create(:authority, full_name: "Example Council", website_url: "https://example.nsw.gov.au")
      )

      render "instructions_body"

      expect(rendered).to include "<a href=\"https://example.nsw.gov.au\">Example Council</a>"
    end
  end

  context "when the authority does not have a website url" do
    it "render it's name with no link" do
      assign(
        :authority,
        create(:authority, full_name: "Example Council", website_url: nil)
      )

      render "instructions_body"

      expect(rendered).to_not include "<a href='https://example.nsw.gov.au'>Example Council</a>"
      expect(rendered).to include "Example Council"
    end
  end
end
