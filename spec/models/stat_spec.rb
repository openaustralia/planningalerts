# frozen_string_literal: true

require "spec_helper"

describe Stat do
  describe ".applications_sent" do
    it "reads in the number of applications that have gone out in emails" do
      described_class.delete_all
      described_class.create!(key: "applications_sent", value: 14)

      expect(described_class.applications_sent).to eq(14)
    end

    it "returns 0 when a key is missing and create the key" do
      described_class.delete_all
      # Stat.logger.should_receive(:error).with("Could not find key applications_sent for Stat lookup")
      expect(described_class.applications_sent).to eq(0)
      expect(described_class.find_by(key: "applications_sent").value).to eq(0)
    end
  end

  describe ".increment_applications_sent" do
    it "increments the stat atomically" do
      described_class.delete_all
      described_class.create!(key: "applications_sent", value: 4)
      described_class.increment_applications_sent(3)
      expect(described_class.applications_sent).to eq 7
    end
  end

  describe ".increment_emails_sent" do
    it "increments the stat atomically" do
      described_class.delete_all
      described_class.create!(key: "emails_sent", value: 14)
      described_class.increment_emails_sent(10)
      expect(described_class.emails_sent).to eq 24
    end
  end

  describe ".emails_sent" do
    it "reads in the number of emails that have been sent" do
      described_class.delete_all
      described_class.create!(key: "emails_sent", value: 2)

      expect(described_class.emails_sent).to eq(2)
    end
  end
end
