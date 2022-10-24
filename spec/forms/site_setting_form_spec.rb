# frozen_string_literal: true

require "spec_helper"

describe SiteSettingForm do
  describe "#streetview_in_emails_enabled=" do
    it "casts to boolean" do
      s = described_class.new(streetview_in_emails_enabled: 0)
      expect(s.streetview_in_emails_enabled).to be false
    end
  end
end
