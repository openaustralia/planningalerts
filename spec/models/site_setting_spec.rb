# frozen_string_literal: true

require "spec_helper"

describe SiteSetting do
  describe ".streetview_in_emails_enabled" do
    it "should be enabled by default" do
      expect(SiteSetting.streetview_in_emails_enabled).to be true
    end
  end

  describe ".streetview_in_emails_enabled=" do
    it "should create a new record" do
      SiteSetting.streetview_in_emails_enabled = false
      expect(SiteSetting.count).to eq 1
      expect(SiteSetting.first.settings).to eq(
        streetview_in_emails_enabled: false
      )
    end

    it "can be read back out" do
      SiteSetting.streetview_in_emails_enabled = false
      expect(SiteSetting.streetview_in_emails_enabled).to be false
    end

    it "should created multiple records if updated multiple times" do
      SiteSetting.streetview_in_emails_enabled = false
      SiteSetting.streetview_in_emails_enabled = true
      expect(SiteSetting.count).to eq 2
    end

    it "should read back out if updated multiple times" do
      SiteSetting.streetview_in_emails_enabled = false
      SiteSetting.streetview_in_emails_enabled = true
      expect(SiteSetting.streetview_in_emails_enabled).to be true
    end

    it "should not overwrite other values" do
      SiteSetting.create!(settings: { other_value: "foo" })
      SiteSetting.streetview_in_emails_enabled = false
      expect(SiteSetting.settings).to eq(
        other_value: "foo", streetview_in_emails_enabled: false
      )
    end
  end

  describe ".settings" do
    it "should be an empty array by default" do
      expect(SiteSetting.settings).to eq({})
    end
  end
end
