# frozen_string_literal: true

require "spec_helper"

describe ApplicationVersion do
  describe "validations" do
    describe "date_scraped" do
      it { expect(build(:application_version, date_scraped: nil)).not_to be_valid }
    end

    describe "address" do
      it { expect(build(:application_version, address: "")).not_to be_valid }
    end

    describe "description" do
      it { expect(build(:application_version, description: "")).not_to be_valid }
    end

    describe "info_url" do
      it { expect(build(:application_version, info_url: "")).not_to be_valid }
      it { expect(build(:application_version, info_url: "http://blah.com?p=1")).to be_valid }
      it { expect(build(:application_version, info_url: "foo")).not_to be_valid }
    end

    describe "date_received" do
      it { expect(build(:application_version, date_received: nil)).to be_valid }

      context "when the date today is 1 january 2001" do
        around do |test|
          Timecop.freeze(Date.new(2001, 1, 1)) { test.run }
        end

        it { expect(build(:application_version, date_received: Date.new(2002, 1, 1))).not_to be_valid }
        it { expect(build(:application_version, date_received: Date.new(2000, 1, 1))).to be_valid }
      end
    end

    describe "on_notice" do
      it { expect(build(:application_version, on_notice_from: nil, on_notice_to: nil)).to be_valid }
      it { expect(build(:application_version, on_notice_from: Date.new(2001, 1, 1), on_notice_to: Date.new(2001, 2, 1))).to be_valid }
      it { expect(build(:application_version, on_notice_from: nil, on_notice_to: Date.new(2001, 2, 1))).to be_valid }
      it { expect(build(:application_version, on_notice_from: Date.new(2001, 1, 1), on_notice_to: nil)).to be_valid }
      it { expect(build(:application_version, on_notice_from: Date.new(2001, 2, 1), on_notice_to: Date.new(2001, 1, 1))).not_to be_valid }
    end

    describe "current" do
      # Creates a bare application with no application versions
      let(:application1) do
        application = create(:geocoded_application)
        application.versions.destroy_all
        application
      end

      let(:application2) do
        application = create(:geocoded_application)
        application.versions.destroy_all
        application
      end

      it "allows multiple versions for the same application that are not current" do
        create(:geocoded_application_version, application: application1, current: false)
        version2 = build(:application_version, application: application1, current: false)
        expect(version2).to be_valid
      end

      it "allows one version for the same application to be current with second version current" do
        create(:geocoded_application_version, application: application1, current: false)
        version2 = build(:application_version, application: application1, current: true)
        expect(version2).to be_valid
      end

      it "allows one version for the same application to be current with first version current" do
        create(:geocoded_application_version, application: application1, current: true)
        version2 = build(:application_version, application: application1, current: false)
        expect(version2).to be_valid
      end

      it "does not allow more than one version to be current" do
        create(:geocoded_application_version, application: application1, current: true)
        version2 = build(:application_version, application: application1, current: true)
        expect(version2).not_to be_valid
      end

      it "allows more than one version to be current for different applications" do
        create(:geocoded_application_version, application: application1, current: true)
        version2 = build(:application_version, application: application2, current: true)
        expect(version2).to be_valid
      end
    end
  end

  describe "#changed_data_attributes" do
    let(:version) { create(:geocoded_application_version) }

    it "returns all data_attributes if only version" do
      expect(version.changed_data_attributes).to eq version.data_attributes
    end

    it "returns just what's changed" do
      date_scraped = 1.minute.ago
      new_version = create(
        :geocoded_application_version,
        previous_version: version,
        description: "A new description",
        date_scraped:
      )
      expect(new_version.changed_data_attributes).to eq(
        "description" => "A new description",
        "date_scraped" => new_version.date_scraped
      )
    end
  end
end
