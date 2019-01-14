# frozen_string_literal: true

require "spec_helper"

describe SiteSettingForm do
  describe "#streetview_in_emails_enabled=" do
    it "should cast to boolean" do
      s = SiteSettingForm.new(streetview_in_emails_enabled: 0)
      expect(s.streetview_in_emails_enabled).to eq false
    end
  end
end
