# frozen_string_literal: true

require "spec_helper"

describe "councillor_contributions/_instructions_body" do
  context "when the authority has a website url" do
    let(:authority) { create(:authority, full_name: "Example Council", website_url: "https://example.nsw.gov.au") }

    it "render a link to the website" do
      render "instructions_body", authority: authority

      expect(rendered).to include "<a title=\"Go to the Example Council website.\" target=\"_blank\" href=\"https://example.nsw.gov.au\">Example Council website</a>"
    end
  end

  context "when the authority does not have a website url" do
    let(:authority) { create(:authority, full_name: "Example Council", website_url: nil) }

    it "render its name with no link" do
      render "instructions_body", authority: authority

      expect(rendered).to_not include "<a title=\"Go to the Example Council website.\" target=\"_blank\" href=\"https://example.nsw.gov.au\">Example Council</a>"
      expect(rendered).to include "Example Council"
    end
  end
end
