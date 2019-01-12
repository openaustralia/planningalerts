# frozen_string_literal: true

require "spec_helper"

describe SiteSetting do
  describe ".get" do
    it "should return the default value if nothing else is set" do
      expect(SiteSetting.get(:streetview_in_emails_enabled, false)).to be false
      expect(SiteSetting.get(:streetview_in_emails_enabled, true)).to be true
    end
  end

  describe ".set" do
    it "should create a new record" do
      SiteSetting.set(:streetview_in_emails_enabled, false)
      expect(SiteSetting.count).to eq 1
      expect(SiteSetting.first.settings).to eq(
        streetview_in_emails_enabled: false
      )
    end

    it "can be read back out" do
      SiteSetting.set(:streetview_in_emails_enabled, false)
      expect(SiteSetting.get(:streetview_in_emails_enabled, true)).to be false
    end

    it "should created multiple records if updated multiple times" do
      SiteSetting.set(:streetview_in_emails_enabled, false)
      SiteSetting.set(:streetview_in_emails_enabled, true)
      expect(SiteSetting.count).to eq 2
    end

    it "should read back out if updated multiple times" do
      SiteSetting.set(:streetview_in_emails_enabled, false)
      SiteSetting.set(:streetview_in_emails_enabled, true)
      expect(SiteSetting.get(:streetview_in_emails_enabled, true)).to be true
    end

    it "should not overwrite other values" do
      SiteSetting.set(:other_value, "foo")
      SiteSetting.set(:streetview_in_emails_enabled, false)
      expect(SiteSetting.get(:other_value, nil)).to eq "foo"
    end
  end
end
