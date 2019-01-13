# frozen_string_literal: true

require "spec_helper"

describe SiteSetting do
  describe ".get" do
    it "should be enabled by default" do
      expect(SiteSetting.get(:streetview_in_emails_enabled)).to be true
    end

    it "should raise an error if using an unknown param" do
      expect { SiteSetting.get(:this_does_not_exist) }.to raise_error(RuntimeError)
    end
  end

  describe ".set" do
    it "should create a new record" do
      SiteSetting.set(streetview_in_emails_enabled: false)
      expect(SiteSetting.count).to eq 1
      expect(SiteSetting.first.settings).to eq(
        streetview_in_emails_enabled: false
      )
    end

    it "can be read back out" do
      SiteSetting.set(streetview_in_emails_enabled: false)
      expect(SiteSetting.get(:streetview_in_emails_enabled)).to be false
    end

    it "should created multiple records if updated multiple times" do
      SiteSetting.set(streetview_in_emails_enabled: false)
      SiteSetting.set(streetview_in_emails_enabled: true)
      expect(SiteSetting.count).to eq 2
    end

    it "should read back out if updated multiple times" do
      SiteSetting.set(streetview_in_emails_enabled: false)
      SiteSetting.set(streetview_in_emails_enabled: true)
      expect(SiteSetting.get(:streetview_in_emails_enabled)).to be true
    end

    it "should not overwrite other values" do
      SiteSetting.set(streetview_in_app_enabled: "foo")
      SiteSetting.set(streetview_in_emails_enabled: false)
      expect(SiteSetting.get(:streetview_in_app_enabled)).to eq "foo"
    end

    it "should be able to update several params at once" do
      SiteSetting.set(streetview_in_app_enabled: "foo", streetview_in_emails_enabled: false)
      expect(SiteSetting.get(:streetview_in_app_enabled)).to eq "foo"
      expect(SiteSetting.get(:streetview_in_emails_enabled)).to eq false
    end
  end
end
