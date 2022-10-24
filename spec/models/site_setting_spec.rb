# frozen_string_literal: true

require "spec_helper"

describe SiteSetting do
  describe ".get" do
    it "is enabled by default" do
      expect(described_class.get(:streetview_in_emails_enabled)).to be true
    end

    it "raises an error if using an unknown param" do
      expect { described_class.get(:this_does_not_exist) }.to raise_error(RuntimeError)
    end
  end

  describe ".set" do
    it "creates a new record" do
      described_class.set(streetview_in_emails_enabled: false)
      expect(described_class.count).to eq 1
      expect(described_class.first.settings).to eq(
        streetview_in_emails_enabled: false
      )
    end

    it "can be read back out" do
      described_class.set(streetview_in_emails_enabled: false)
      expect(described_class.get(:streetview_in_emails_enabled)).to be false
    end

    it "createds multiple records if updated multiple times" do
      described_class.set(streetview_in_emails_enabled: false)
      described_class.set(streetview_in_emails_enabled: true)
      expect(described_class.count).to eq 2
    end

    it "reads back out if updated multiple times" do
      described_class.set(streetview_in_emails_enabled: false)
      described_class.set(streetview_in_emails_enabled: true)
      expect(described_class.get(:streetview_in_emails_enabled)).to be true
    end

    it "does not overwrite other values" do
      described_class.set(streetview_in_app_enabled: "foo")
      described_class.set(streetview_in_emails_enabled: false)
      expect(described_class.get(:streetview_in_app_enabled)).to eq "foo"
    end

    it "is able to update several params at once" do
      described_class.set(streetview_in_app_enabled: "foo", streetview_in_emails_enabled: false)
      expect(described_class.get(:streetview_in_app_enabled)).to eq "foo"
      expect(described_class.get(:streetview_in_emails_enabled)).to be false
    end
  end
end
